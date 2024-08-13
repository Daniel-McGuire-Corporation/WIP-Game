import tkinter as tk
from tkinter import filedialog, messagebox, Toplevel, Scrollbar, Canvas

class LevelEditor(tk.Tk):
    def __init__(self):
        super().__init__()

        self.title("Level Editor")
        self.geometry("800x600")
        self.state('zoomed')  # Start in maximized state
        self.iconbitmap('edit.ico')

        self.file_path = None  # Track the current file path
        self.text_edit = tk.Text(self, bg='#121212', fg='#FFFFFF', insertbackground='white')
        self.text_edit.pack(expand=True, fill=tk.BOTH)

        self.create_menu()
        self.bind_shortcuts()

    def create_menu(self):
        menubar = tk.Menu(self, bg='#333333', fg='#FFFFFF')
        self.config(menu=menubar)

        # File Menu
        file_menu = tk.Menu(menubar, tearoff=0, bg='#444444', fg='#FFFFFF')
        menubar.add_cascade(label="File", menu=file_menu)
        
        file_menu.add_command(label="Open", command=self.open_file, accelerator="Ctrl+O")
        file_menu.add_command(label="Save", command=self.save_file, accelerator="Ctrl+S")
        file_menu.add_command(label="Save As", command=self.save_as_file, accelerator="Ctrl+Shift+S")
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.quit)

        # Preview Menu
        preview_menu = tk.Menu(menubar, tearoff=0, bg='#444444', fg='#FFFFFF')
        menubar.add_cascade(label="Preview", menu=preview_menu)
        
        preview_menu.add_command(label="Preview Level", command=self.show_preview, accelerator="Ctrl+P")

    def bind_shortcuts(self):
        self.bind_all("<Control-o>", lambda e: self.open_file())
        self.bind_all("<Control-s>", lambda e: self.save_file())
        self.bind_all("<Control-Shift-S>", lambda e: self.save_as_file())
        self.bind_all("<Control-p>", lambda e: self.show_preview())

    def open_file(self):
        file_path = filedialog.askopenfilename(defaultextension=".level",
                                               filetypes=[("Development Levels", "*.level"),
                                                          ("Release Levels", "*.ini"),
                                                          ("All Files", "*.*")])
        if file_path:
            try:
                with open(file_path, 'r') as file:
                    content = file.read()
                    self.text_edit.delete(1.0, tk.END)
                    self.text_edit.insert(tk.END, content)
                    self.file_path = file_path  # Save the path of the opened file
            except Exception as e:
                messagebox.showerror("Open File", f"Cannot open file: {str(e)}")

    def save_file(self):
        if self.file_path:
            try:
                with open(self.file_path, 'w') as file:
                    content = self.text_edit.get(1.0, tk.END)
                    file.write(content)
            except Exception as e:
                messagebox.showerror("Save File", f"Cannot save file: {str(e)}")
        else:
            self.save_as_file()

    def save_as_file(self):
        file_path = filedialog.asksaveasfilename(defaultextension=".level",
                                                filetypes=[("Level Files", "*.level"),
                                                           ("INI Files", "*.ini"),
                                                           ("All Files", "*.*")])
        if file_path:
            try:
                with open(file_path, 'w') as file:
                    content = self.text_edit.get(1.0, tk.END)
                    file.write(content)
                self.file_path = file_path  # Update the current file path
            except Exception as e:
                messagebox.showerror("Save File", f"Cannot save file: {str(e)}")

    def show_preview(self):
        if not self.file_path:
            messagebox.showwarning("Preview", "No file opened. Please open a file first.")
            return

        preview_window = Toplevel(self)
        preview_window.title("Level Editor - Preview Pane")
        preview_window.geometry("800x600")
        preview_window.resizable(False, False)  # Disable resizing
        preview_window.attributes('-toolwindow', True)  # Disable maximizing

        # Create canvas and scrollbar
        self.canvas = Canvas(preview_window, bg='#121212', width=800, height=600)
        scrollbar = Scrollbar(preview_window, orient='horizontal', command=self.canvas.xview)
        self.canvas.configure(xscrollcommand=scrollbar.set)

        # Pack scrollbar and canvas
        scrollbar.pack(side='bottom', fill='x')
        self.canvas.pack(side='left', fill='both', expand=True)

        # Initialize canvas_frame
        self.canvas_frame = tk.Frame(self.canvas, bg='#121212')
        self.canvas.create_window((0, 0), window=self.canvas_frame, anchor='nw')

        # Update preview
        self.update_preview()

    def update_preview(self):
        # Clear the canvas_frame
        for widget in self.canvas_frame.winfo_children():
            widget.destroy()

        # Reload canvas_frame
        self.canvas_frame = tk.Frame(self.canvas, bg='#121212')
        self.canvas.create_window((0, 0), window=self.canvas_frame, anchor='nw')

        # Load and parse the level file
        tile_size = 40
        colors = {
            'G': '#00FF00',  # Green for ground
            '1': '#FF0000',  # Red for platforms
            '0': '#121212',  # Dark grey for empty spaces
        }

        try:
            with open(self.file_path, 'r') as file:
                lines = file.readlines()

            # Determine the size of the canvas
            max_width = max(len(line.strip()) for line in lines)
            canvas_width = max_width * tile_size
            canvas_height = len(lines) * tile_size
            self.canvas.config(scrollregion=(0, 0, canvas_width, canvas_height))

            # Draw tiles
            for y, line in enumerate(lines):
                for x, char in enumerate(line.strip()):
                    color = colors.get(char, '#121212')  # Default to dark grey if char not found
                    self.canvas.create_rectangle(
                        x * tile_size, y * tile_size,
                        (x + 1) * tile_size, (y + 1) * tile_size,
                        fill=color, outline='#333333'
                    )

        except Exception as e:
            messagebox.showerror("Preview", f"Cannot load preview: {str(e)}")

if __name__ == "__main__":
    app = LevelEditor()
    app.mainloop()
