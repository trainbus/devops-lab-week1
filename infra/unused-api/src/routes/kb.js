import express from 'express'
const router = express.Router()
router.get('/:slug', (req, res) => {
  res.json({ slug: req.params.slug, content: "# KB Page Example" })
})
router.put('/:slug', (req, res) => {
  res.json({ message: "Page saved", slug: req.params.slug })
})
export default router

