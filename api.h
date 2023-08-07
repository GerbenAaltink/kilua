
// extern "C" {
#include <lua.h>     /* Always include this when calling Lua */
#include <lauxlib.h> /* Always include this when calling Lua */
#include <lualib.h>  /* Prototype for luaL_openlibs(), */
                     /*   always include this when calling Lua */
//}
#include <stdlib.h> /* For function exit() */
                    /* For input/output */

void (*editorSetStatusMessageHook)(const char *fmt, ...);

void bail(lua_State *L, char *msg)
{
    fprintf(stderr, "\nFATAL ERROR:\n  %s: %s\n\n",
            msg, lua_tostring(L, -2));
    exit(2);
}

lua_State *L;

void closeLua()
{
    lua_close(L);
}

void initLua()
{
    L = luaL_newstate(); /* Create Lua state variable */
    luaL_openlibs(L);    /* Load Lua libraries */

    if (luaL_loadfile(L, "/home/gerben/projects/kilua/api.lua")) /* Load but don't run the Lua script */
        bail(L, "luaL_loadfile() failed");                      /* Error out if file can't be read */

    if (lua_pcall(L, 0, 0, 0))         /* PRIMING RUN. FORGET THIS AND YOU'RE TOAST */
        bail(L, "lua_pcall() failed"); /* Error out if Lua file has an error */

}

void luaTriggerEvent(char *name, int param)
{

    lua_getglobal(L, "event"); /* Tell it to run callfuncscript.lua->square() */
    lua_pushstring(L, name);
    lua_pushinteger(L, param);
    if (lua_pcall(L, 2, 2, 0)) /* Run function, !!! NRETURN=2 !!! */
        bail(L, "lua_pcall() failed");
    const char *statusText = lua_tostring(L, -2);
    editorSetStatusMessageHook(statusText);
}
