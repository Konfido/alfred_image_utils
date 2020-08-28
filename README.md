# Image Utils Workflow

Alfred Workflow which can take a set of PNG/JPG/gif files and compress them by using some local utils or the online [TinyPNG](https://tinypng.com/) service. Please make sure you have made all  [dependencies](#Dependencies) installed.

(Note: The free TinyPNG API has a monthly limit of 500 file processes per month.)



## Usage

- Online processing

    Your images will be uploaded to TinyPNG, and the processed files will be downloaded to a TinyPNG folder on your Desktop, along with a Report showing the success/failure of each file, and how much it has been compressed by.

    - Triggered by File Action: `Image - Compress with TinyPNG`
        1. Select the PNG or JPG files (in Finder or Alfred)
        2. Press hotkey to trigger the File Action in Alfred.
    - Triggered by Keyword
        1. Select the PNG or JPG files you want processed in Finder, 
        2. Launch Alfred, and then use the “tinypng" keyword.

- Local processing

    - Triggered by File Action
        - Image - Compress locally
        - Image - Round Corner
        - Image - Resize
        - Image - Concact Horizontally

    

## Dependencies

- `tinify`: TinyPNG's API to compress and optimize JPEG and PNG images
    - `pip install --upgrade tinify`

- `pngquant`, `jpegoptim`, `figsicle` : Tools used for local image processing.
    - `brew install pngquant jpegoptim gifsicle`





## Acknowledgement

- The original version of this workflow is integrated and refactored from [TinyPNG](http://www.packal.org/workflow/tinypng) and [Alfred Gallery](https://github.com/BlackwinMin/alfred-gallery).

- The workflow's icon is made by [Freepik](https://www.flaticon.com/authors/freepik) from [www.flaticon.com](https://www.flaticon.com/).











































































