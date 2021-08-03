# Flame Graph Viewer

Profiles an application using `perf` and displays a flame graph. Alpha software; see the security note below.

The `perf` utility is invaluable for understanding the performance of linux applications, but can be tedious to use, especially on remote systems. Brendan Gregg has a fantastic [flame graph generator](https://github.com/brendangregg/FlameGraph) but it still requires a number of manual steps. `flame-viewer` stitches everything together to allow for quick iterations. No more hunting for pids!

## Requirements

- Ruby 2.x
- Sinatra (`gem install sinatra`)
- `perf`
- sudo access

## Installation

```bash
git clone https://github.com/mnutt/flame-viewer.git
```

My process for running this is typically:
- Create an ssh tunnel to a remote system via `ssh -L 5555:localhost:5555 yoursystem`
- Clone `flame-viewer`
- Start `flame-viewer`, scoped to only the process(es) you care about: (for example, `nginx`)

```
PROC_PATTERN="nginx" ruby app.rb -p 5555
```

Then open http://localhost:5555 to get started profiling.

## Security

This project has not undergone any sort of security review. **DO NOT EXPOSE IT TO THE INTERNET**. When using it on remote systems, only use it via the ssh tunneling described above.

Even when used in the manner described above, there may be security holes. Some areas for concern:

* The app can expose a list of processes running on your system, which may include sensitive parameters. Use as narrow a `PROC_PATTERN` as possible.
* Running `perf` typically requires `sudo` access. (modifying the system to run it without `sudo` may open up other attack vectors) **Do not** run `flame-viewer` itself with sudo.
* The flame view itself shows function names which could theoretically leak sensitive information about a process.

## TODO

* Validation to prevent insecure misuse as described above
* Consider rewriting in golang so that the entire app can be used as a self-contained binary
* More `perf` configuration


## License

Copyright 2021 Michael Nutt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
