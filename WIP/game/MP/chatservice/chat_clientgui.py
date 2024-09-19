import tkinter as tk
from tkinter import simpledialog, messagebox, scrolledtext
import socket
import threading

class ChatClient:
    def __init__(self, root):
        self.root = root
        self.root.title("Untitled Game | Chat:")

        # Initialize GUI components
        self.text_area = scrolledtext.ScrolledText(root, state='disabled', wrap='word')
        self.text_area.pack(expand=True, fill='both', padx=10, pady=10)

        self.message_entry = tk.Entry(root)
        self.message_entry.pack(side='left', expand=True, fill='x', padx=10, pady=10)
        self.message_entry.bind('<Return>', self.send_message)

        self.send_button = tk.Button(root, text="Send", command=self.send_message)
        self.send_button.pack(side='right', padx=10, pady=10)

        # Prompt for server info
        self.server_address = None
        self.server_port = None
        self.username = None
        self.client_socket = None

        self.prompt_for_connection()

    def prompt_for_connection(self):
        # Prompt for server address
        self.server_address = simpledialog.askstring("Server Address", "Enter server address:")
        if not self.server_address:
            self.root.quit()
            return
        
        # Prompt for server port
        self.server_port = simpledialog.askinteger("Server Port", "Enter server port:", minvalue=1, maxvalue=65535)
        if not self.server_port:
            self.root.quit()
            return
        
        # Prompt for username
        self.username = simpledialog.askstring("Username", "Enter your username:")
        if not self.username:
            self.root.quit()
            return
        
        # Connect to the server
        self.connect_to_server()

    def connect_to_server(self):
        try:
            self.client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.client_socket.connect((self.server_address, self.server_port))
            self.client_socket.sendall(self.username.encode('utf-8'))
            
            # Start the thread to receive messages
            self.receive_thread = threading.Thread(target=self.receive_messages)
            self.receive_thread.daemon = True
            self.receive_thread.start()
            
            self.text_area.configure(state='normal')
            self.text_area.insert(tk.END, f"Connected to {self.server_address}:{self.server_port}\n")
            self.text_area.configure(state='disabled')
        except Exception as e:
            messagebox.showerror("Connection Error", f"Error connecting to server: {e}")
            self.root.quit()

    def send_message(self, event=None):
        message = self.message_entry.get()
        if message:
            full_message = f"{message}"
            try:
                self.client_socket.sendall(full_message.encode('utf-8'))
                self.message_entry.delete(0, tk.END)
                self.text_area.configure(state='normal')
                self.text_area.insert(tk.END, full_message + "\n")
                self.text_area.configure(state='disabled')
                self.text_area.yview(tk.END)
            except Exception as e:
                messagebox.showerror("Send Error", f"Error sending message: {e}")

    def receive_messages(self):
        while True:
            try:
                message = self.client_socket.recv(1024).decode('utf-8')
                if message:
                    self.text_area.configure(state='normal')
                    self.text_area.insert(tk.END, message + "\n")
                    self.text_area.configure(state='disabled')
                    self.text_area.yview(tk.END)
                else:
                    self.show_error("Disconnected from server")
                    break
            except Exception as e:
                self.show_error(f"Error receiving message: {e}")
                break

    def show_error(self, message):
        self.text_area.configure(state='normal')
        self.text_area.insert(tk.END, f"ERROR: {message}\n")
        self.text_area.configure(state='disabled')

def main():
    root = tk.Tk()
    client = ChatClient(root)
    root.mainloop()

if __name__ == "__main__":
    main()
