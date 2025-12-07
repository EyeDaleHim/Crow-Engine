# About

Crow Engine is a framework for Friday Night Funkin' that uses declarative data structures to display content.

The general comparison is that Crow Engine gives you less control over objects, states, and the flow directly, this is in part that the engine doesn't offer a lot of imperative options like scripting, but ideally, the way Crow Engine should be built is that the developer must avoid creating a lot of original logic as much as possible.

The advantage of Crow Engine is that despite its limited control, it still gives enough control to be comparable to other engines through predicate data files, object filtering, and events, without relying on imperative behavior.

The idea of Crow Engine's data-driven design comes from the fact that developers often duplicate a lot of logic in their source-code mods, which can result in inconsistent implementation or poor practices. Another factor is that developers don't really need that much power or control over the features they want to implement, so Crow Engine offers a unique path by giving developers the appropriate amount of control and a certain option over how data flows.

Additionally, Crow Engine was also made with personal use in mind, and any feature or infrastructure implemented is generally prioritizing my own needs before others. However, this does not imply that documentation or quality-of-life features will be cut if it disrupts my workflow as feedback towards the engine is also feedback towards my workflow.

## Risks
Crow Engine requires a higher level of skill floor than other Friday Night Funkin' engines like Psych Engine due to the amount of
behavior you have to define explicitly.

## Modding
Crow Engine does not offer any options for mod folders or load mods itself, it is only expected to load content from its assets folder. In such cases, mods made with Crow Engine will need to be distributed as one compressed package, either with or without the executable, adding onto the original asset folder or replacing it entirely.

## Loading Songs
Crow Engine treats songs as levels, including their difficulty and variants. This solves the issue where a song's difficulty is locked to its suffix defined by the engine. This can also scale as you don't need to explicitly define a mix variant or difficulty of a song, or both. 

# Credits

- [EyeDaleHim](https://github.com/EyeDaleHim) Main developer and maintainer of Crow Engine.
- [FNF Team](https://github.com/FunkinCrew) For making the funky rhythm game we all know and love.
- [Rudyrue](https://github.com/Rudyrue/) Menu references as seen [here](https://github.com/Rudyrue/custom-psych).

## Alumni
- [SwickTheGreat](https://weldedflap.carrd.co/) - Major Contributor
- [AmeliaTheSharmi](https://www.youtube.com/@AmeliaTheSharmi) - Logo Artist
- [Rapper GF](https://twitter.com/Rapper_GF_Dev) - Circular Buffer Suggestion
- **Cherry** - Circular Buffer improvements
