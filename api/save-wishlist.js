import { sql } from '@vercel/postgres';

export default async function handler(request, response) {
    if (request.method !== 'POST') {
        return response.status(405).json({ error: 'Method not allowed' });
    }

    const { owner, wishes } = request.body;

    try {
        let wishlistResult = await sql`
            SELECT id FROM wishlists WHERE owner = ${owner}
        `;

        let wishlistId;

        if (wishlistResult.rows.length > 0) {
            wishlistId = wishlistResult.rows[0].id;

            // Delete existing wishes
            await sql`
                DELETE FROM wishes WHERE wishlist_id = ${wishlistId}
            `;
        } else {
            wishlistResult = await sql`
                INSERT INTO wishlists (owner)
                VALUES (${owner})
                RETURNING id
            `;
            wishlistId = wishlistResult.rows[0].id;
        }

        // Insert new wishes
        for (let wish of wishes) {
            await sql`
                INSERT INTO wishes (content, wishlist_id)
                VALUES (${wish.content}, ${wishlistId})
            `;
        }

        return response.status(201).json({ id: wishlistId });
    } catch (error) {
        console.error(error);
        return response.status(500).json({ error });
    }
}