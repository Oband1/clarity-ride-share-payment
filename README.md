# Decentralized Ride-Sharing Payment System

A blockchain-based payment system for ride-sharing services built on the Stacks network using Clarity.

## Features

- Create and manage ride records
- Track ride completion status
- Handle secure payments between passengers and drivers
- Immutable ride history
- Trustless payment execution
- Rating system for both drivers and passengers
- Dispute resolution system with partial refund capability

## How it works

1. Ride is created with specific fare and participants
2. Driver marks ride as completed
3. Passenger can then execute payment
4. Both parties can rate each other (1-5 stars)
5. Passengers can file disputes with refund requests
6. Contract owner can resolve disputes and process refunds
7. All transactions are recorded on chain

## Security

- Only contract owner can create rides and resolve disputes
- Only assigned driver can mark rides complete
- Only assigned passenger can make payment
- Payment only possible after ride completion
- Double-payment prevention
- Rating constraints (1-5 stars only)
- Dispute system with built-in refund mechanism

## Rating System

The rating system allows:
- Drivers to rate passengers
- Passengers to rate drivers
- Ratings from 1-5 stars
- One rating per party per ride
- Ratings only after ride completion

## Dispute Resolution

The dispute system enables:
- Passengers to file disputes with detailed reasons
- Requesting specific refund amounts
- Contract owner to mediate disputes
- Partial or full refund processing
- Tracking of dispute status and resolutions
