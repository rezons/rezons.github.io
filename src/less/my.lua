return require("magic"){
  what= "guess",
  when= "(c) 2021, timm@ieee.org, unlicense.org",
  how = {
    {"misc", "todo", "-do","help", "start up action"},
    {"",     "seed", "-S", 10019,  "random number seed"},
    {"",     "help", "-h", false,  "show help test"},
    {"keep", "keep", "-k", 20,     "things to keep in best"},
    {"dist", "p",    "-p", 2,      "distance exponent"},
    {"",     "some", "-s", 128,    "sample size for dist"}}
}
