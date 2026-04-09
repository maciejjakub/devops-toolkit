## isolated agentic environment
Run Claude Code for free using other models for generating responses. 

### Build and run
Mount the volume to container for persistence
```
docker build -t isoagenv .
docker run -it -e OPENROUTER_API_KEY="your-key-here" -v $(pwd)/workspace:/home/ligma/workspace isoagenv
```