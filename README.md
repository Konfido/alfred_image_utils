# Alfred Workflow - Image Utils

Using local CLIs or the [TinyPNG](https://tinypng.com/) service to process images (PNG/JPG/gif). 

Notes: 

- The free TinyPNG API has a monthly limit of 500 file processes per month.
- Please make sure you have made all  [dependencies](#Dependencies) installed.



## Usage

- Online processing

    Your images will be uploaded to TinyPNG, and the processed files and a report will be downloaded to a TinyPNG folder on your Desktop. Available services include compressing and resize (scale, fit cover, thumb). Please check out [tinypny api](https://tinypng.com/developers/reference) for further info.

    - Triggered by File Action: 
        1. Select the image files in Finder or Alfred
        2. Press hotkey (default `⌘⌥\`) to trigger the File Action in Alfred.
        3. Select File Actions:
            - `Image - Compress with TinyPNG`
            - `Image - Resize with TinyPNG`
    - Triggered by Keyword: 
        1. Select images files in Finder
        
        2. Launch Alfred, and use the following keywords.
        
            - `compress with tinypng`
        
            - `resize with tinypng`

- Local processing

    - Triggered by File Action
        - `Image - Rename (locally)`: change images' name to the format of '%Y%m%d%H%M%S%f'
        - `Image - Compress locally`
        - `Image - Resize`
        - `Image - Round Corner`
    - `Image - Concact Horizontally`
    
    

## Dependencies

- `pngquant`, `jpegoptim`, `figsicle` : Tools used for local image processing.
    - `brew install pngquant jpegoptim gifsicle`





## Acknowledgement

- The original version of this workflow is integrated and refactored from [TinyPNG](http://www.packal.org/workflow/tinypng) and [Alfred Gallery](https://github.com/BlackwinMin/alfred-gallery).

- The workflow's icon is made by [Freepik](https://www.flaticon.com/authors/freepik) from [www.flaticon.com](https://www.flaticon.com/).

