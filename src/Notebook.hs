
{- |
Rough and ready Notebook.


This is needed only for stand-alone pandoc processing, to fully display long source lines (see https://stackoverflow.com/questions/73078541/markdown-to-html-via-pandoc-full-page-width):

``` {=html}
<style>
body { min-width: 95% !important;}
</style>
```

To display the code correctly, include it into a markdown code block:

```haskell
-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE FlexibleContexts          #-}
{-# LANGUAGE NamedFieldPuns            #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE OverloadedStrings         #-}
{-# LANGUAGE StrictData                #-}
{-# LANGUAGE TypeFamilies              #-}

module Notebook where

import           Codec.Picture            (PixelRGB8 (PixelRGB8),
                                           PngSavable (encodePng),
                                           generateImage)
import qualified Data.ByteString          as B
import           Data.ByteString.Base64   (encode)
import qualified Data.ByteString.Encoding as E
import qualified Data.ByteString.Lazy     as L
import           Data.Text                (Text)
import qualified Data.Text                as T
import           Data.Text.Lazy           (unpack)
import           Diagrams.Backend.SVG     (Options (SVGOptions), SVG (SVG))
import           Diagrams.Prelude         (Default (def), darkred, frame, hrule,
                                           lc, lw, medium, mkWidth, reflectX,
                                           reflectY, renderDia, rotateBy,
                                           strokeT, vrule, ( # ))
import           Graphics.Svg.Core        (renderText)
import           Text.Pandoc              (Alignment (AlignLeft), Block (Plain),
                                           Caption (Caption), Cell (Cell),
                                           ColSpan (ColSpan),
                                           ColWidth (ColWidthDefault),
                                           Inline (Str), Pandoc, Row (Row),
                                           RowHeadColumns (RowHeadColumns),
                                           RowSpan (RowSpan),
                                           TableBody (TableBody),
                                           TableFoot (TableFoot),
                                           TableHead (TableHead),
                                           WriterOptions (writerExtensions),
                                           multimarkdownExtensions, nullAttr,
                                           runIOorExplode, writeHtml5String,
                                           writeMarkdown)
import           Text.Pandoc.Builder      (doc, singleton)
import qualified Text.Pandoc.Builder      as P
import           Web.Data.Yahoo.API       (fetchLatest)
import           Web.Data.Yahoo.Response  (PriceResponse (PriceResponse, open))

{-
```

A PNG image, generated using JuicyPixels and displayed as an inline image.

>>> png anImage
<p><img src="data:image/png;base64,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"/></p>

```haskell
-}

png :: B.ByteString -> ()
png img = error $ concat ["<p><img src=\"data:image/png;base64,",T.unpack . E.decode E.utf8 . encode $ img,"\"/></p>"]

anImage :: B.ByteString
anImage = L.toStrict . encodePng $ generateImage pixelRenderer 50 50
   where pixelRenderer x y = PixelRGB8 (fromIntegral x * 8) (fromIntegral y * 8) 128


{-
```

Show a Math formula.

>>> formula $ foldr (\n b -> concat["(",b,")^",show n]) "a+b" [2..5]
$$((((a+b)^5)^4)^3)^2$$

```haskell
-}
formula :: [Char] -> ()
formula f = error $ concat ["$$",f,"$$"]


{-
```

Show a Pie Chart using mermaid.

>>> pie $ PieChart "Animals" [("Dogs",11.1),("Cats",22.2),("Humans",33.3)]
```mermaid
pie
title Animals
"Dogs":11.1
"Cats":22.2
"Humans":33.3
```


```haskell
-}
data PieChart = PieChart {pieTitle :: String,pieVals :: [(String,Double)]} deriving Show

pie :: PieChart -> ()
pie p = error $ unlines $ ["```mermaid"
  ,"pie"
  ,"title " ++ pieTitle p] ++ map (\(n,v) -> concat [show n,":",show v]) (pieVals p)
  ++ ["```"]


{-
```

Show a dependency graph using mermaid.

>>> dep [("A","B"),("A","C"),("B","D"),("C","D")]
```mermaid
graph TD;
A-->B;
A-->C;
B-->D;
C-->D;
```

```haskell
-}
dep :: [(String, String)] -> a
dep vs =  error $ unlines $ ["```mermaid"
  ,"graph TD;"
  ] ++ map (\(n,v) -> concat [n,"-->",v,";"]) vs
  ++ ["```"]

{-
```
Generate a complex diagram and show it as SVG.

>>> svg hilbertCurve
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
    "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"><svg xmlns="http://www.w3.org/2000/svg" height="250.0000" viewBox="0.0 0.0 250.0 250.0" font-size="1" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" stroke-opacity="1" width="250.0000" stroke="rgb(0,0,0)"><defs></defs><g stroke-width="0.9999999999999999" fill="rgb(0,0,0)" stroke-linecap="butt" stroke-linejoin="miter" stroke-opacity="1.0" fill-opacity="0.0" stroke="rgb(139,0,0)" stroke-miterlimit="10.0"><path d="M 7.5758,7.5758 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 h 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 l 0.0000,7.5758 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 h -7.5758 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 l 0.0000,7.5758 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 h -7.5758 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 h -7.5758 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 h -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 h -7.5758 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 l 0.0000,7.5758 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 h -7.5758 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 h 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 h 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 h -7.5758 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 l -0.0000,-7.5758 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 h 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 l 0.0000,7.5758 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 h -7.5758 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 h 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 h 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 h -7.5758 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 l -0.0000,-7.5758 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 h -7.5758 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 h -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 h -7.5758 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 h -7.5758 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 l -0.0000,-7.5758 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 h -7.5758 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 l -0.0000,-7.5758 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l 0.0000,7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 l -7.5758,0.0000 v -7.5758 h -7.5758 v 7.5758 v 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 h 7.5758 l 7.5758,-0.0000 l 0.0000,7.5758 l -7.5758,0.0000 v 7.5758 v 7.5758 h 7.5758 v -7.5758 h 7.5758 v 7.5758 h 7.5758 v -7.5758 v -7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 v -7.5758 v -7.5758 h -7.5758 v 7.5758 l -7.5758,0.0000 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l -0.0000,-7.5758 l -7.5758,0.0000 l -0.0000,-7.5758 l 7.5758,-0.0000 l 7.5758,-0.0000 v 7.5758 h 7.5758 v -7.5758 "/></g></svg>

```haskell
-}

-- |Show a diagram as svg
svg = error . unpack . renderText . renderDia SVG (SVGOptions (mkWidth 250) Nothing "" [] True)

hilbert 0 = mempty
hilbert n = hilbert' (n-1) # reflectY <> vrule 1
         <> hilbert  (n-1) <> hrule 1
         <> hilbert  (n-1) <> vrule (-1)
         <> hilbert' (n-1) # reflectX
  where
    hilbert' m = hilbert m # rotateBy (1/4)

hilbertCurve = frame 1 . lw medium . lc darkred . strokeT $ hilbert 5


{-
```

A simple financial data table:

>>> stocks = stockTable [Stock "Alphabet" "GOOG",Stock "General Motors" "GM",Stock "Amazon" "AMZN"]


Shown as Markdown:

>>> md stocks
>>>>| Name           | Yahoo ID | Price     |
>>>>|:---------------|:---------|:----------|
>>>>| Alphabet       | GOOG     | 95.5      |
>>>>| General Motors | GM       | 41.009998 |
>>>>| Amazon         | AMZN     | 98.769997 |


Shown as HTML:

>>> h stocks
<table>
<thead>
<tr class="header" style="border:1px solid black">
<th style="text-align: left;" style="border:1px solid black">Name</th>
<th style="text-align: left;" style="border:1px solid black">Yahoo ID</th>
<th style="text-align: left;" style="border:1px solid black">Price</th>
</tr>
</thead>
<tbody>
<tr class="odd" style="border:1px solid black">
<td style="text-align: left;" style="border:1px solid black">Alphabet</td>
<td style="text-align: left;" style="border:1px solid black">GOOG</td>
<td style="text-align: left;" style="border:1px solid black">95.5</td>
</tr>
<tr class="even" style="border:1px solid black">
<td style="text-align: left;" style="border:1px solid black">General Motors</td>
<td style="text-align: left;" style="border:1px solid black">GM</td>
<td style="text-align: left;" style="border:1px solid black">41.009998</td>
</tr>
<tr class="odd" style="border:1px solid black">
<td style="text-align: left;" style="border:1px solid black">Amazon</td>
<td style="text-align: left;" style="border:1px solid black">AMZN</td>
<td style="text-align: left;" style="border:1px solid black">98.769997</td>
</tr>
</tbody>
</table>

```haskell
-}

-- | A basic financial data table
stockTable :: [Stock] -> Table Stock
stockTable = Table [Col "Name" (return . stkName),Col "Yahoo ID" (return . stkYahooId),Col "Price" price]


-- | A financial stock
data Stock = Stock {stkName::Text,stkYahooId::Text} deriving (Show,Eq)

-- | Retrieve Stock's current price
price:: Stock -> IO Text
price stk = do
  r <- fetchLatest (T.unpack $ stkYahooId stk)
  return $ case r of
    Right PriceResponse {open} -> T.pack $ show open
    Left _                     -> "Not Available"

-- | A data table
data Table v = Table {
    cols  ::Cols v -- ^ columns/value properties
    ,vals ::[v]   -- ^ the values
    }

type Cols a = [Col a]

-- | A data table column
-- data Col v = forall o. Show o => Col {
data Col v =  Col {
  colName ::Text       -- ^ column name
  ,colOp  :: v -> IO Text  -- ^ a function that return the column value
  }


-- | The '>>>' expressions' value is by default displayed as a single line
-- to display it on multiple lines we need to return it as an exception

-- | Return a Table as multi-line HTML
h :: Table v -> IO ()
h t = asHTML t >>= error . T.unpack

-- | Return a Table as multi-line Markdown
-- To display it correctly we need to 'escape' every line
-- prefixing it with '>>>>'
md :: Table v -> IO ()
md t = asMD t >>= error . T.unpack . T.unlines . map (T.append  ">>>>") .  T.lines

-- | Return a Table as HTML, using Pandoc
asHTML :: Table v -> IO Text
asHTML t = table t >>= runIOorExplode . writeHtml5String def . asDoc

-- | Return a Table as Markdown, using Pandoc
asMD :: Table v -> IO Text
asMD t = table t >>= runIOorExplode . writeMarkdown def{writerExtensions =  multimarkdownExtensions} . asDoc

asDoc :: Block -> Pandoc
asDoc = doc . singleton

{- |
Directly generating a markdown or HTML table is easy enough,

but here we take the high road and map to a Pandoc table and then generate Markdown/HTML tables from it.
-}
table :: Table v -> IO Block
table t = do
    let cs = cols t
    let colsValues v = mapM (\(Col _ f) -> f v) cs
    rows <- mapM (fmap row . colsValues) $ vals t
    return $ P.Table
        nullAttr
        (Caption (Just [Str "Values Table"]) [])
        (map (const (AlignLeft,ColWidthDefault)) cs)
        (TableHead nullAttr [row  $ map colName cs])
        [TableBody nullAttr (RowHeadColumns 0) [] rows]
        (TableFoot nullAttr [])
            where
                row ss = Row border $ map (\s -> Cell border AlignLeft (RowSpan 1) (ColSpan 1) [Plain [Str s]]) ss
                border = ("", [], [("style", "border:1px solid black")])

{-
```

-}

