import { sql } from '@vercel/postgres';
const withAuth = require('../../middlewares/withAuth');

module.exports = withAuth(async (request, response) => {
    const { username } = request.query;

    try {
        const wishlistResult = await sql`
            SELECT w.id, w.content
            FROM wishlists wl
            JOIN wishes w ON wl.id = w.wishlist_id
            WHERE wl.owner = ${username}
        `;

        if (wishlistResult.rows.length === 0) {
            return response.status(404).json({ error: 'Wishlist not found' });
        } else {
            const wishlist = {
                owner: username,
                wishes: wishlistResult.rows.map(row => ({ content: row.content }))
            };

            return response.status(200).json(wishlist);
        }
    } catch (error) {
        console.error(error);
        return response.status(500).json({ error });
    }
});
