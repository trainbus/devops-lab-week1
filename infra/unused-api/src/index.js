import express from 'express'
import mongoose from 'mongoose'
import cors from 'cors'
import dotenv from 'dotenv'
dotenv.config()

const app = express()
app.use(express.json())
app.use(cors())

const MONGO_URI = process.env.MONGO_URI
mongoose.connect(MONGO_URI)
  .then(() => console.log("✅ MongoDB connected"))
  .catch(err => console.error("MongoDB error:", err))

app.get('/api/health', (_, res) => res.json({ status: "ok" }))
app.use('/api/comments', (await import('./routes/comments.js')).default)
app.use('/api/kb', (await import('./routes/kb.js')).default)

const PORT = process.env.PORT || 3000
app.listen(PORT, () => console.log(`🚀 API running on port ${PORT}`))

