import express from 'express'
const router = express.Router()
router.get('/recent', (_, res) => res.json([{ id: 1, author: "Derrick", text: "Welcome!", date: new Date() }]))
export default router

