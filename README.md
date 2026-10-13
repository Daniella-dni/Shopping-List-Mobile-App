# Shopping List+

A full-featured Flutter shopping list application built for Mobile Programming (Week 2, Session 3).

The app allows users to manage grocery items with quantities, prevent duplicates, filter active and completed items, undo accidental deletions, and view/edit detailed item information on a dedicated details screen.

---

## Features

1. **Empty State ("Nothing to show")**:
   - Displays a clean `"Your list is empty"` message when all items are deleted instead of an empty white screen.
   - As soon as an item is added, the list reappears instantly.

2. **Quantities ("How many?")**:
   - Every item starts with a quantity of `1`.
   - Each item row features `−` and `+` buttons alongside the quantity counter.
   - The quantity increments with `+` and decrements with `−`, adhering to the business rule that quantity **never drops below 1**. Complete item deletion is reserved for the delete bin.

3. **Smart Duplicate Prevention ("No duplicates, just more")**:
   - Case-insensitive and whitespace-trimmed matching prevents accidental duplicates (e.g. adding `"  milk  "` when `"Milk"` is present).
   - Instead of creating a duplicate row, the existing item's quantity increments by 1 and a feedback SnackBar notifies the user: `"<Item> is already on the list: now ×<qty>"`.

4. **Deletion with Undo ("Oops: undo")**:
   - Deleting an item triggers a `SnackBar` displaying `"<Item> removed"` with an **Undo** action button.
   - Tapping **Undo** restores the item to its **exact original index** in the list, preserving its quantity, note, category, and bought status.

5. **Dual Filters & Sorting ("Show me what's left" + "Push further")**:
   - **Status Filters**: Three chips under the input row: **All**, **To buy**, and **Bought**.
   - **Category Filters**: Filter dynamically by category: **All**, **Food**, **Drinks**, and **Home**.
   - **Alphabetical Sorting (A → Z)**: An action button in the `AppBar` toggles A to Z sorting on and off.
   - **Smart Sort Ordering**: When sorted, unbought items are ordered alphabetically, and bought items are **always placed at the bottom** (also sorted alphabetically).
   - If a selected filter has no matching items, a `"Nothing here"` message appears.
   - All actions (toggling bought, `−`, `+`, deleting, and undoing) work across all filters and sort states.

6. **Item Details Screen ("Item details")**:
   - Long-pressing any item opens a dedicated **Item details** screen with an `AppBar` and back arrow.
   - Allows viewing and editing the item's **Name**, a descriptive **Note** (e.g., *the 1 litre bottle*), and a **Category** selected via chips (**Food**, **Drinks**, **Home**).
   - Tapping **Save** validates that the name is not empty and persists changes back to the list.
   - Tapping the back arrow returns without modifying anything.
   - The main list shows category and notes below the title: `Category · note`.

---

## Screenshots

> Place your emulator/phone screenshots inside the `screenshots/` directory with these filenames.

### Core Features (Session 3 Base)
| My List | Item Bought (Crossed out) | Empty Item Refused |
| :---: | :---: | :---: |
| ![My list](screenshots/list.png) | ![An item bought](screenshots/bought.png) | ![An empty item refused](screenshots/empty.png) |

### Shopping List+ Upgrades
| Quantities (− / +) | Undo SnackBar | Filter Chips | Item Details Screen |
| :---: | :---: | :---: | :---: |
| ![Quantities](screenshots/quantities.png) | ![Undo](screenshots/undo.png) | ![Filters](screenshots/filters.png) | ![Details Screen](screenshots/details.png) |

---

## Think

### 1. In part 5, why does deleting by `index` remove the wrong item when a filter is on? How did you fix it?
When a filter like "Bought" or "To buy" is active, `ListView.builder` displays indices corresponding to the filtered list (`shown`), not the primary master list (`items`). For instance, if item 0 in the filtered view corresponds to item 3 in the master list, calling `items.removeAt(index)` removes item 0 of the master list (a completely different item).
**Fix**: We remove by the object reference itself (`items.remove(item)`). Additionally, before removing the item, we locate its true index in the master list using `final originalIndex = items.indexOf(item);` so that the **Undo** action can accurately restore it with `items.insert(originalIndex, item)`.

### 2. Why did you have to remove `final` from `name`? Why is `final` still a good choice for most fields?
A field declared as `final` can only be initialized once and cannot be reassigned. Because Part 6 requires editing the item's name from the `DetailsScreen`, `name` needs to be mutable (`widget.item.name = updatedName`). 
However, `final` is still a good choice for most fields in Dart and Flutter because immutability prevents unintended side effects, simplifies debugging, makes data flow predictable, and enables compiler optimizations during widget builds.

### 3. Why did you need a hot restart after adding `quantity` to `Item`, when a save was enough for everything else?
Hot reload injects updated widget build methods and layout logic into the running Dart VM while preserving in-memory state. Because the existing `items` list was already created and held in memory before the new `quantity` field and default values were added to the `Item` class, hot reload cannot re-run top-level initializers or restructure already-allocated objects. A **hot restart** restarts the Dart VM from `main()`, clearing existing memory and instantiating fresh `Item` objects that include the new `quantity` field.

### 4. The details screen changed the item, but the list only showed it after `setState` in `.then`. Why? What does this tell you about how Flutter decides when to redraw?
In Flutter, modifying a plain Dart object's properties in memory does not automatically notify the widget tree to rebuild. Flutter is reactive and relies on explicit signals—such as `setState()`, `InheritedWidget`, or state management notifiers—to know when a widget's appearance is dirty and needs to be repainted. Attaching `.then((_) { setState(() {}); })` to `Navigator.push` ensures that once the route is popped, Flutter schedules a rebuild of `ShoppingListScreenState`, causing `build()` to run and display the modified item values.

---

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio with Android SDK & Emulator / physical device

### Running the App
1. Clone the repository:
   ```bash
   git clone https://github.com/<your-username>/shopping_list.git
   cd shopping_list
   ```
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. Run on your connected emulator or device:
   ```bash
   flutter run
   ```
