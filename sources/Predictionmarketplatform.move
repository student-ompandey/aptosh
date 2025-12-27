module wallet_address::PredictionMarket {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a prediction market event
    struct Market has store, key {
        total_yes_bets: u64,    // Total tokens bet on YES outcome
        total_no_bets: u64,     // Total tokens bet on NO outcome
        is_resolved: bool,      // Whether the market has been resolved
        winning_outcome: bool,  // True for YES, False for NO
    }

    /// Struct to track individual user bets
    struct UserBet has store, key {
        yes_amount: u64,        // Amount bet on YES
        no_amount: u64,         // Amount bet on NO
        has_claimed: bool,      // Whether user has claimed winnings
    }

    /// Function to create a new prediction market
    public fun create_market(creator: &signer) {
        let market = Market {
            total_yes_bets: 0,
            total_no_bets: 0,
            is_resolved: false,
            winning_outcome: false,
        };
        move_to(creator, market);
    }

    /// Function to place a bet on the prediction market
    public fun place_bet(
        bettor: &signer, 
        market_owner: address, 
        amount: u64, 
        bet_on_yes: bool
    ) acquires Market {
        let market = borrow_global_mut<Market>(market_owner);
        let bettor_addr = signer::address_of(bettor);

        // Transfer bet amount to market owner
        let bet_coin = coin::withdraw<AptosCoin>(bettor, amount);
        coin::deposit<AptosCoin>(market_owner, bet_coin);

        // Update market totals
        if (bet_on_yes) {
            market.total_yes_bets = market.total_yes_bets + amount;
        } else {
            market.total_no_bets = market.total_no_bets + amount;
        };
    }
}