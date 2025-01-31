# Decentralized Ride-Sharing Payment System

A blockchain-based payment system for ride-sharing services built on the Stacks network using Clarity.

## Features

- Create and manage ride records
- Track ride completion status
- Handle secure payments between passengers and drivers
- Immutable ride history
- Trustless payment execution

## How it works

1. Ride is created with specific fare and participants
2. Driver marks ride as completed
3. Passenger can then execute payment
4. All transactions are recorded on chain

## Security

- Only contract owner can create rides
- Only assigned driver can mark rides complete
- Only assigned passenger can make payment
- Payment only possible after ride completion
- Double-payment prevention
