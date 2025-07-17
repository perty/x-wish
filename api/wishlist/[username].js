import { sql } from '@vercel/postgres';
import withAuth from '../../middlewares/withAuth.js';

export default withAuth(async (request, response) => {
    const { username } = request.query;

    try {
        const wishlistResult = await sql`
            SELECT w.id, w.content, w.fulfilled_by
            FROM wishlists wl
            JOIN wishes w ON wl.id = w.wishlist_id
            WHERE wl.owner = ${username}
        `;

        if (wishlistResult.rows.length === 0) {
            return response.status(404).json({ error: 'Wishlist not found' });
        } else {
            const wishlist = {
                owner: username,
                wishes: wishlistResult.rows.map(row => ({
                    id: row.id,
                    content: row.content,
                    fulfilledBy: row.fulfilled_by
                }))
            };

            return response.status(200).json(wishlist);
        }
    } catch (error) {
        console.error(error);
        return response.status(500).json({ error });
    }
});
