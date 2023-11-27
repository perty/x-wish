# X-wish

[![ci](https://github.com/perty/x-wish/actions/workflows/ci.yml/badge.svg)](https://github.com/perty/x-wish/actions/workflows/ci.yml)

An application built by GitHub Copilot.

##  Chapter 1

### Post on LinkedIn

This is a post I wrote on [LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7134449617051561985?utm_source=share&utm_medium=member_desktop).

I have spent two days on a project where I let myself depend heavily on GitHub Copilot. 

I have one such project under the belt already. A small test where I
(we) made a Markdown editor and deployed it to Vercel. I had never used
Vercel earlier.

Here is the result including the initial prompt: [perty/elm-vite-test](https://github.com/perty/elm-vite-test).

This time, I wanted to make something more involved with a database and 
multiuser with sharing between users. 

My focus has been on prompting and not writing the code. I was curious about where prompting focus would take the project. 

The impression was that AI acted a bit like a buddy that I pair program with and who knows more than I do about some of the tech stack. 

But of course there are some differences. 

One observation is the rabbit hole syndrome. AI has endless patience, unlike a
human. So if, or rather when, my reasoning goes down a rabbit hole, it just tags
along and try to help me. A human would get impatient and say "let's try 
something different ".

I was impressed by its structured reasoning when we had an issue with the
database calls. First, it asked me to insert a print statement when I presented 
the problem "server error". That gave some information, and it asked for another 
print at another place, which gave enough information to solve it and suggest a 
change. 

This iterative process to solving mimics human behaviour very well.

I got the itch several times to write the code myself, which is much like saying "give me the keyboard " when pair programming. But I resisted that and I think it was beneficial to the project. 😃

One thing the AI does, unlike most human pair programmers, is planning. 
I come up with an idea, and it goes "great, then we need to do these
things" and gives a list of things. 

The project is far from finished, so I hopefully will have more to 
share later on.

### Complete dialogue

The complete dialogue is here: [doc/prompts/chapter1.md](doc/prompts/chapter1.md).

### State

It is a hideous application. Functionally wise, it has user authentication, a wish list and wishes. A user can look at other
user's wishlists if they know their username.

Authentication is done with a username and a password. No support for restoring a forgotten password. In fact there is no support for signing up. I have to create users through the REST API.
