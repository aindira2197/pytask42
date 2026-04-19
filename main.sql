CREATE TABLE Clients (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    ip_address VARCHAR(255),
    port INT,
    status VARCHAR(255)
);

CREATE TABLE Servers (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    ip_address VARCHAR(255),
    port INT,
    status VARCHAR(255)
);

INSERT INTO Clients (id, name, ip_address, port, status) 
VALUES 
(1, 'Client1', '192.168.1.100', 8080, 'Connected'),
(2, 'Client2', '192.168.1.101', 8081, 'Disconnected');

INSERT INTO Servers (id, name, ip_address, port, status) 
VALUES 
(1, 'Server1', '192.168.1.200', 8082, 'Running'),
(2, 'Server2', '192.168.1.201', 8083, 'Stopped');

CREATE TABLE Messages (
    id INT PRIMARY KEY,
    client_id INT,
    server_id INT,
    message_text TEXT,
    send_time TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES Clients(id),
    FOREIGN KEY (server_id) REFERENCES Servers(id)
);

CREATE PROCEDURE sendMessage(@client_id INT, @server_id INT, @message_text TEXT)
BEGIN
    INSERT INTO Messages (client_id, server_id, message_text, send_time) 
    VALUES (@client_id, @server_id, @message_text, NOW());
END;

CREATE FUNCTION getLastMessage(@client_id INT, @server_id INT)
RETURNS TEXT
BEGIN
    DECLARE last_message TEXT;
    SELECT message_text INTO last_message 
    FROM Messages 
    WHERE client_id = @client_id AND server_id = @server_id 
    ORDER BY send_time DESC LIMIT 1;
    RETURN last_message;
END;

CREATE TRIGGER updateClientStatus AFTER INSERT ON Messages
FOR EACH ROW
BEGIN
    UPDATE Clients 
    SET status = 'Connected' 
    WHERE id = NEW.client_id;
END;

CREATE TRIGGER updateServerStatus AFTER INSERT ON Messages
FOR EACH ROW
BEGIN
    UPDATE Servers 
    SET status = 'Running' 
    WHERE id = NEW.server_id;
END;

CREATE VIEW clientServerMessages AS
SELECT c.name AS client_name, s.name AS server_name, m.message_text, m.send_time
FROM Messages m
JOIN Clients c ON m.client_id = c.id
JOIN Servers s ON m.server_id = s.id;

CREATE INDEX idx_client_id ON Messages (client_id);
CREATE INDEX idx_server_id ON Messages (server_id);

CALL sendMessage(1, 1, 'Hello, server!');
SELECT * FROM clientServerMessages;
SELECT * FROM Clients;
SELECT * FROM Servers;
SELECT getLastMessage(1, 1);