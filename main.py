import socket
import threading

class Server:
    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server.bind((self.host, self.port))
        self.server.listen()

    def handle_client(self, conn, addr):
        print(f"Yangi ulanish: {addr}")
        while True:
            try:
                message = conn.recv(1024)
                if not message:
                    break
                print(f"{addr}: {message.decode('utf-8')}")
                conn.send(message)
            except:
                break
        print(f"Ulanish tugatildi: {addr}")
        conn.close()

    def start(self):
        print(f"Server {self.host}:{self.port} da ishga tushdi")
        while True:
            conn, addr = self.server.accept()
            thread = threading.Thread(target=self.handle_client, args=(conn, addr))
            thread.start()

class Client:
    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.client.connect((self.host, self.port))

    def send_message(self, message):
        self.client.send(message.encode('utf-8'))
        response = self.client.recv(1024)
        print(f"Serverdan: {response.decode('utf-8')}")

    def start(self):
        while True:
            message = input("Siz: ")
            self.send_message(message)
            if message.lower() == "xit":
                break
        self.client.close()

if __name__ == "__main__":
    server = Server("127.0.0.1", 55555)
    client = Client("127.0.0.1", 55555)
    import tkinter as tk
    from threading import Thread

    def server_start():
        server_thread = Thread(target=server.start)
        server_thread.start()

    def client_start():
        client_thread = Thread(target=client.start)
        client_thread.start()

    root = tk.Tk()
    server_button = tk.Button(root, text="Serverni ishga tushirish", command=server_start)
    server_button.pack()
    client_button = tk.Button(root, text="Clientni ishga tushirish", command=client_start)
    client_button.pack()
    root.mainloop()