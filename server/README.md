# Socket.IO Chat Server

## Setup

1. Install Node.js if not already installed
2. Install dependencies:
   ```bash
   cd server
   npm install
   ```

## Run Server

Development mode (auto-restart):
```bash
npm run dev
```

Production mode:
```bash
npm start
```

Server will run on http://localhost:3000

## Socket Events

### Client → Server
- `join_chat`: Join a chat room
- `send_message`: Send a message
- `typing`: User is typing
- `stop_typing`: User stopped typing

### Server → Client
- `receive_message`: New message received
- `user_joined`: User joined the chat
- `user_left`: User left the chat
- `user_typing`: Another user is typing
- `user_stop_typing`: Typing indicator off
