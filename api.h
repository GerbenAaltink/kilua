
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <stdlib.h>

// TODO: give better name starting with lua
void (*editorSetStatusMessageHook)(const char *fmt, ...);

void bail(lua_State *L, char *msg)
{
    fprintf(stderr, "\nFATAL ERROR:\n  %s: %s\n\n",
            msg, lua_tostring(L, -2));
    exit(2);
}

lua_State *L;


// TODO: get nowhere called yet
void closeLua()
{
    lua_close(L);
}

void initLua()
{
    L = luaL_newstate();
    luaL_openlibs(L);

    // TODO: Make whole Lua optional and make path relative
    if (luaL_loadfile(L, "/home/gerben/projects/kilua/api.lua"))
        bail(L, "luaL_loadfile() failed");

    if (lua_pcall(L, 0, 0, 0))         /* PRIMING RUN. FORGET THIS AND YOU'RE TOAST */
        bail(L, "lua_pcall() failed"); /* Error out if Lua file has an error */
}

void luaTriggerEvent(char *name, int param)
{
    lua_getglobal(L, "event");
    lua_pushstring(L, name);
    lua_pushinteger(L, param);
    if (lua_pcall(L, 2, 2, 0))
        bail(L, "lua_pcall() failed");
    const char *statusText = lua_tostring(L, -2);
    editorSetStatusMessageHook(statusText);
}
