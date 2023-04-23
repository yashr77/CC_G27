#include "scopeheader.hh"

bool scopetable::present(std::string key)
{
    return scope[s].find(key) != scope[s].end();
}

int scopetable::get(std::string key)
{
    int temp = s;
    while (temp >= 0)
    {
        if (scope[temp].find(key) != scope[temp].end())
            return scope[temp][key];
        temp--;
    }
    return -1;
}

void scopetable::insert(std::string key, int value)
{
    scope[s][key] = value;
    return;
}

void scopetable::dec()
{
    scope.erase(s);
    s--;
}

void scopetable::inc()
{
    s++;
}

void scopetable::update(std::string key, int value)
{
    int temp = s;
    if (scope[s].find(key) != scope[temp].end())
    {
        scope[temp][key] = value;
        return;
    }
    while (temp >= 0)
    {
        if (scope[temp].find(key) != scope[temp].end())
        {
            scope[temp][key] = value;
            return;
        }
        temp--;
    }
    return;
}