# autopair.fish

> Auto-complete matching pairs in the [Fish](https://fishshell.com) command line.

Automatically insert, erase, and skip matching pairs as you type in the command-line: `()`, `[]`, `{}`, `""`, and `''`. E.g., pressing `(` inserts `()` and positions the cursor in between the parentheses. Hopefully.

- Insert matching pairs.

  ```console
  $ echo β’ # Let's say βͺ is the cursor!
  ```

  <kbd>"</kbd> π₯

  ```console
  $ echo "βͺ"
  ```

- Erase pairs on backspace:

  ```console
  $ echo "Heyβͺ"
  ```

  <kbd>Backspace</kbd> π₯π₯π₯

  ```console
  $ echo "βͺ"
  ```

  <kbd>Backspace</kbd> π₯

  ```console
  $ echo βͺ
  ```

- Skip over matched pairs:

  ```console
  $ echo "Heyβͺ"
  ```

  <kbd>"</kbd> π₯

  ```console
  $ echo "Hey"βͺ
  ```

- Gracefully handle <kbd>Tab</kbd> completions for variables while inside double quotes.

  ```console
  $ echo "$fish_color_βͺ"
  ```

  <kbd>Tab</kbd> π₯

  ```console
  $ echo "$fish_color_βͺ
  "$fish_color_autosuggestion   (Variable: '555' 'brblack')
  "$fish_color_cancel           (Variable: -r)
  "$fish_color_command          (Variable: blue)
  "$fish_color_comment          (Variable: red)
  ...
  ```

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher):

```console
fisher install jorgebucaran/autopair.fish
```

## License

[MIT](LICENSE.md)
