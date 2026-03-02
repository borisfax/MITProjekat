# Candy Shop - Monorepo

Aplikacija za prodaju bombona sa Flutter frontom i Node.js/Express backendom.

## Pokretanje

### Backend
```bash
cd backend
npm install
cp .env.example .env
# Uredi .env sa tvojim MONGO_URI
npm run dev
```
Server će biti dostupan na `http://localhost:5000`

### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## Struktura
- `/backend` - Node.js/Express API
- `/frontend` - Flutter aplikacija
