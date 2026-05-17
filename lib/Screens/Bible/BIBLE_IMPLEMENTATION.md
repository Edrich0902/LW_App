# Bible Feature Implementation Details

## Overview
The Bible integration in the LW App provides a seamless reading experience by connecting to the YouVersion Platform API. It supports version selection, book and chapter navigation, and sequential reading across books.

## Architecture

### State Management (BLoC)
The `BibleBloc` manages the complexity of sequential navigation and state transitions:
- **Reactive State:** Uses `BibleLoaded` with an `isLoading` flag to perform background updates (like fetching next chapters) without full-screen flickers.
- **Sequential Navigation:** 
    - `NavigateNextChapter`: Advances to the next chapter. If at the end of a book, it automatically switches to Chapter 1 of the next book.
    - `NavigatePreviousChapter`: Goes back to the previous chapter. If at the beginning of a book, it fetches the previous book's metadata and jumps to its last chapter.
- **Filtering:** State includes full lists of `versions` and `books`, which are filtered in the UI layer for search functionality.

### UI Components
- **`BiblePage`**: The main reading interface. Uses a `Stack` to overlay floating navigation buttons.
- **`BibleNavigationSheet`**: A reactive `ModalBottomSheet` that uses `BlocBuilder` to ensure it always displays current data. Includes real-time search for versions and books.
- **`Html` Rendering**: Uses `flutter_html` with custom CSS and regex-based pre-processing to ensure verse numbers are formatted as branded gold superscripts.

## Key Implementation Patterns

### 1. Sequential Navigation Logic
```dart
// Logic for moving between books automatically
if (currentIndex < currentState.chapters.length - 1) {
  add(ChangeChapter(currentState.chapters[currentIndex + 1]));
} else {
  final currentBookIndex = currentState.books.indexWhere((b) => b.id == currentState.currentBook.id);
  if (currentBookIndex < currentState.books.length - 1) {
    add(ChangeBook(currentState.books[currentBookIndex + 1]));
  }
}
```

### 2. Verse Formatting (Regex + CSS)
Since the YouVersion API returns varying HTML structures, we use a robust pre-processor:
- **Regex**: Identifies raw numbers preceded by space/boundary and followed by letters/non-breaking spaces.
- **CSS**: Targets `.v`, `.yv-vlbl`, and `sup` tags with `VerticalAlign.sup` and branded gold coloring.

### 3. Reactive Sheet pattern
Instead of passing a static state to the BottomSheet, it uses its own `BlocBuilder`. This allows the sheet to "react" to book selections made in the "Boek" tab by immediately updating the "Hoofstuk" grid when the BLoC state changes in the background.

## Technical Findings
- **Vertical Alignment**: In `flutter_html`, the correct enum value for superscript is `VerticalAlign.sup` (not `super`).
- **YouVersion Classes**: Common classes to style include `.yv-vlbl` (verse labels), `.v` (generic verse markers), and `.s1`/`.s2` (headings).
- **Background Loading**: Using `emit(state.copyWith(isLoading: true))` allows for showing a `LinearProgressIndicator` instead of a full-screen `LwpLoader`, significantly improving the perceived performance during chapter switches.
