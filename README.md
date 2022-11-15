# Transform your old and tired Haskell source files in  shining Notebooks 

Have you ever suffered of Notebook envy?

Have you ever felt a pang of jealousy for Python programmers and their cool data science Jupyter notebooks?

The most complete antidote to this particular form of existential angst is installing Haskell's own [Jupyter backend](https://hackage.haskell.org/package/ihaskell).

But, if like most Haskell developers these days, you use the [Haskell Language Server](https://github.com/haskell/haskell-language-server) and [VS Code](https://code.visualstudio.com/) you can immediately transform any Haskell source file in a rough and ready notebook without any additional configuration and without the need to run another bulky server.

# Demo

Check this [example](src/Notebook.hs) of generating and displaying:

* mathematical formulas

* images

* all kind if charts and graphs

* [diagrams](https://hackage.haskell.org/package/diagrams)

* data tables


![Demo](notebook.gif)


Demo video captured using [LICECap](https://www.cockos.com/licecap/).

# Now You Do It

* Install the VS Code extension [Markdown Everywhere](https://marketplace.visualstudio.com/items?itemName=zhaouv.vscode-markdown-everywhere). This will istruct VS Code to display Markdown/HTML code embedded in Haskell comments.

* Optional: Install a [Mermaid](https://mermaid-js.github.io/mermaid) VS Code extension like [Markdown Mermaid](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid).

* Generate Markdown/HTML code in Haskell comments using HLS's built-in [eval plugins](https://github.com/haskell/haskell-language-server/blob/master/plugins/hls-eval-plugin/README.md). Check [src/Notebook.hs](src/Notebook.hs) for a few worked out examples. 

* Type **Ctrl-K V** in the Haskell source file to open the sideline Markdown preview 

# Run the Example File Locally

```bash
git clone https://github.com/tittoassini/notebook.git
cd notebook;stack build
```

Note: compilation will take a long time as the examples use a varity of large packages ([pandoc](https://hackage.haskell.org/package/pandoc), [diagrams](https://hackage.haskell.org/package/diagrams), etc.).

Open [src/Notebook.hs](src/Notebook.hs) and type **Ctrl-K V**.




