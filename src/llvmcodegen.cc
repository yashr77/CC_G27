#include "llvmcodegen.hh"
#include "ast.hh"
#include <iostream>
#include <llvm/Support/FileSystem.h>
#include <llvm/IR/Constant.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/GlobalValue.h>
#include <llvm/IR/Verifier.h>
#include <llvm/Bitcode/BitcodeWriter.h>
#include <vector>
#include <bits/stdc++.h>
#define MAIN_FUNC compiler->module.getFunction("main")

/*
The documentation for LLVM codegen, and how exactly this file works can be found
ins `docs/llvm.md`
*/

void LLVMCompiler::compile(Node *root) {
    /* Adding reference to print_i in the runtime library */
    // void printi();
    FunctionType *printi_func_type = FunctionType::get(
                                         builder.getVoidTy(),
    {builder.getInt64Ty()},
    false
                                     );
    Function::Create(
        printi_func_type,
        GlobalValue::ExternalLinkage,
        "printi",
        &module
    );
    /* we can get this later
        module.getFunction("printi");
    */

    /* Main Function */
    // int main();
    FunctionType *main_func_type = FunctionType::get(
                                       builder.getInt64Ty(), {}, false /* is vararg */
                                   );
    Function *main_func = Function::Create(
                              main_func_type,
                              GlobalValue::ExternalLinkage,
                              "main",
                              &module
                          );

    // create main function block
    BasicBlock *main_func_entry_bb = BasicBlock::Create(
                                         *context,
                                         "entry",
                                         main_func
                                     );

    // move the builder to the start of the main function block
    builder.SetInsertPoint(main_func_entry_bb);

    root->llvm_codegen(this);

    // return 0;
    builder.CreateRet(builder.getInt64(0));
}

void LLVMCompiler::dump() {
    outs() << module;
}

void LLVMCompiler::write(std::string file_name) {
    std::error_code EC;
    raw_fd_ostream fout(file_name, EC, sys::fs::OF_None);
    WriteBitcodeToFile(module, fout);
    fout.flush();
    fout.close();
}

//  ┌―――――――――――――――――――――┐  //
//  │ AST -> LLVM Codegen │  //
// └―――――――――――――――――――――┘   //

// codegen for statements
Value *NodeStmts::llvm_codegen(LLVMCompiler *compiler) {
    Value *last = nullptr;
    for (auto node : list) {
        last = node->llvm_codegen(compiler);
    }

    return last;
}

Value *NodeDebug::llvm_codegen(LLVMCompiler *compiler) {
    Value *expr = expression->llvm_codegen(compiler);
    Function *printi_func = compiler->module.getFunction("printi");
    compiler->builder.CreateCall(printi_func, {expr});

    return expr;
}

Value *NodeInt::llvm_codegen(LLVMCompiler *compiler) {
    return compiler->builder.getInt64(value);
}
Value *NodeShort::llvm_codegen(LLVMCompiler *compiler) {
	return compiler->builder.getInt64(value);
}
Value *NodeLong::llvm_codegen(LLVMCompiler *compiler) {
    return compiler->builder.getInt64(value);
}

Value *NodeBinOp::llvm_codegen(LLVMCompiler *compiler) {
    Value *left_expr = left->llvm_codegen(compiler);
    Value *right_expr = right->llvm_codegen(compiler);

    switch (op) {
    case PLUS:
        return compiler->builder.CreateAdd(left_expr, right_expr, "addtmp");
    case MINUS:
        return compiler->builder.CreateSub(left_expr, right_expr, "minustmp");
    case MULT:
        return compiler->builder.CreateMul(left_expr, right_expr, "multtmp");
    case DIV:
        return compiler->builder.CreateSDiv(left_expr, right_expr, "divtmp");
    }
}


Value *NodeDecl::llvm_codegen(LLVMCompiler *compiler) {
    Value *expr = expression->llvm_codegen(compiler);

    IRBuilder<> temp_builder(
        &MAIN_FUNC->getEntryBlock(),
        MAIN_FUNC->getEntryBlock().begin()
    );

    AllocaInst *alloc = temp_builder.CreateAlloca(compiler->builder.getInt64Ty(), 0, identifier);

    compiler->locals[identifier] = alloc;
    compiler->builder.CreateStore(expr, alloc);
    return expr;
}

Value *NodeIdent::llvm_codegen(LLVMCompiler *compiler) {
    AllocaInst *alloc = compiler->locals[identifier];

    // if your LLVM_MAJOR_VERSION >= 14
    return compiler->builder.CreateLoad(compiler->builder.getInt64Ty(), alloc, identifier);
}

Value *NodeIfElse::llvm_codegen(LLVMCompiler *compiler)
{
    Value *CondV = condition->llvm_codegen(compiler);

    if (!CondV)
    {
        return nullptr;
    }
    

    CondV = compiler->builder.CreateICmpNE(
        CondV, ConstantInt::get(Type::getInt64Ty(*(compiler->context)), 0), "ifcond");

    Function *TheFunction = compiler->builder.GetInsertBlock()->getParent();
    BasicBlock *ThenBB = BasicBlock::Create(*compiler->context, "then", TheFunction);
    BasicBlock *ElseBB = BasicBlock::Create(*compiler->context, "else");
    BasicBlock *MergeBB = BasicBlock::Create(*compiler->context, "ifcont");

    compiler->builder.CreateCondBr(CondV, ThenBB, ElseBB);

    compiler->builder.SetInsertPoint(ThenBB);
    Value *ThenV = ifBody->llvm_codegen(compiler);

    compiler->builder.CreateBr(MergeBB);
    ThenBB = compiler->builder.GetInsertBlock();
    //ifBody->type=DBG;
    TheFunction->getBasicBlockList().push_back(ElseBB);
    compiler->builder.SetInsertPoint(ElseBB);
    Value *ElseV = elseBody->llvm_codegen(compiler);
    //elseBody->type=DBG;
    std::cout<<"hi "<<elseBody->type<<std::endl;
    compiler->builder.CreateBr(MergeBB);
    ElseBB = compiler->builder.GetInsertBlock();

    TheFunction->getBasicBlockList().push_back(MergeBB);
    compiler->builder.SetInsertPoint(MergeBB);
    PHINode *PN = compiler->builder.CreatePHI(Type::getInt64Ty(*(compiler->context)), 2, "iftmp");
    //std::cout<<"hi "<<(ThenV->Instruction::getType())<<(PN->Instruction::getType())<<std::endl;
    PN->addIncoming(ThenV, ThenBB);
    PN->addIncoming(ElseV, ElseBB);
    return PN;
}
Value *NodeTest::llvm_codegen(LLVMCompiler *compiler) {
    return NULL;}

Value *NodeFunc::llvm_codegen(LLVMCompiler *compiler) {
    return NULL;}

Value *NodeParam::llvm_codegen(LLVMCompiler *compiler) {
    return NULL;}
// hi 2
// hi 0x170c9400x17108d8
// hi 0x20089e80x200c788
#undef MAIN_FUNC
