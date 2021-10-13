
package.path = '../src/?.lua'
local about=require("about")()
assert(512.5==about.sames + about.bins)
print(about.loud, about.data)
