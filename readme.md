# C/C++ project template
My barebones project structure for c and c++ with flat project structure.
With barebones package manager

## How it works
To build use this command:
```bash
make
# or
make all
```
To run executable use this command

```bash
make run
```

To initialize LSP for vim, emacs , or vscode
```bash
make lsp
```

To download packages
```bash
make package
```
## Config 
Edit config.mk
## Package management
package management format
```bash
package1=("git url"
         "commit hash"
         "build command"
         "libpackage.a"
         "include dirs")

package2=("git url"
         "commit hash"
         "build command"
         "libpackage.a"
         "include dirs")
# then you need to add your package name in
PACKAGES="package1 package2"
```
NOTE: your package's build directory should prefereable be called `build`

