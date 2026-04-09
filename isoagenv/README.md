## isolated agentic environment
Run Claude Code for free using other models for generating responses. 

### Build and run
```
docker build -t isoagenv .
docker run -it -e OPENROUTER_API_KEY="sk-or-..." -v $(pwd)/workspace:/home/ligma/workspace isoagenv
```