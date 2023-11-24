# Notes

## Inital prompt

An application that allows users to create wishlists and share these with their friends. Friends should be able to book which wishes they will fulfill. The person who posted the list cannot see which wishes will be fulfilled. 

Example: Adam has a wishlist with 3 items, socks, shirt and shoes. He shares the wishlist with Eve and Maria. When Eve logs in and sees Adams' list, she marks “shoes” as fulfilling. Maria logs in and sees Adam’s list and that Eve has marked “shoes”. Maria can not select “shoes” now so she selects “shirt” instead and marks it as fulfilling. 

* Use Elm as the main programming language.
* Deploy to Vercel.
* Use Vercel storage, option Postgres.
* Create a model that contains a wish list where each wish is just a text string. 
* Create an interface where the user can add and remove wishes to the list.
* When the users press a button labeled “Save”, the wishlist is saved in the storage.
* Before using the app, users must log in by entering a user name and a password.
* Users may share their wishlist by pressing the “Share” button which gives an Url to the list.
* When looking at another user’s wishlist, each wish can be marked as “fulfilled” by pressing a button next to the wish.
* If the wish is already fulfilled by some other user, there is no button, just the name of the user.
* The data model should reflect that a wishlist is owned by a user and contain a number of wishes.
* Each wish belongs to a wishlist and can be marked as fulfilled by a user.

### Response
To implement this wishlist application, we can follow these steps:

Define the data models: User, Wishlist, and Wish.
Implement user authentication.
Create the interface for adding and removing wishes.
Implement the functionality to save the wishlist.
Implement the functionality to share the wishlist.
Implement the functionality to mark a wish as fulfilled.
Here's a high-level pseudocode representation of the steps:

Define the User model with fields: username, password.
Define the Wishlist model with fields: owner (User), wishes (List of Wish).
Define the Wish model with fields: content (String), fulfilledBy (User).
Implement a login function that authenticates a user.
Implement a function to add a wish to a wishlist.
Implement a function to remove a wish from a wishlist.
Implement a function to save a wishlist in the storage.
Implement a function to share a wishlist, returning a URL to the list.
Implement a function to mark a wish as fulfilled by a user.
Next steps:

Start implementing the data models.
Set up the Elm environment and the Postgres database on Vercel.
Implement the user authentication system.
Create the interface for managing wishlists.
Implement the wishlist sharing functionality.
Implement the wish fulfillment functionality.