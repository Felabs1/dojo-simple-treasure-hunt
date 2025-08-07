use crate::models::Direction;


#[starknet::interface]
pub trait IActions<T> {
    fn spawn(ref self: T);
    fn move_player(ref self: T, direction: Direction);
}

#[dojo::contract]
pub mod actions {
    use super::{IActions};
    use crate::models::{Direction, GameState, MapCell, Player, PlayerTrait};
    use core::num::traits::{SaturatingSub, SaturatingAdd};
    use dojo::model::ModelStorage;

    pub const INIT_COORD: u32 = 0;
    pub const INIT_ENERGY: u32 = 10;
    pub const INIT_SCORE: u32 = 0;

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn spawn(ref self: ContractState) {
            let mut world = self.world_default();
            let player_id = starknet::get_caller_address();

            let player = Player {
                playerId: player_id,
                x: INIT_COORD,
                y: INIT_COORD,
                energy: INIT_ENERGY,
                score: INIT_SCORE,
            };

            let mut treasures = 0;
            // fill in the 5, 5 grid
            let mut x_grid = 0;

            while x_grid < 5 {
                let mut y_grid = 0;
                while y_grid < 5 {
                    let cell_type = if (x_grid == 1 && y_grid == 3) || (x_grid == 4 && y_grid == 2) {
                    treasures += 1;
                    1 // treasures
                    } else if (x_grid == 2 && y_grid == 2) && (x_grid == 3 && y_grid == 4) {
                        2 // trap
                    } else {
                        0 // empty
                    };

                    let cell = MapCell {x: x_grid, y: y_grid, cell_type};
                    world.write_model(@cell);
                    
                    y_grid += 1;
                };
                x_grid += 1;
                
            };

            let game_state = GameState {playerId: player_id, treasures_left: treasures};
            world.write_model(@game_state);
            world.write_model(@player);
        }

        fn move_player(ref self: ContractState, direction: Direction) {
            let mut world = self.world_default();
            // get the person making the call
            let player_id = starknet::get_caller_address();
            // get the player id
            let mut player: Player = world.read_model(player_id);
            // allow the player to make a move
            player.apply_direction(direction);

            // determine the cell where the player is after making a move
            let map_cell:MapCell = world.read_model((player.x, player.y));
            // access the game state for manipulatino
            let mut game_state: GameState = world.read_model(player_id);

            // if the player hit a treasure, he scores something and treasures remaining are deducted from the game
            if map_cell.cell_type == '1'{
                player.score = player.score.saturating_add(10);
                game_state.treasures_left = game_state.treasures_left.saturating_sub(1);

                // if the player hit a trap, the energy is deducted
            } else if map_cell.cell_type == '2' {
                player.energy = player.energy.saturating_sub(1);
            } else {
                // do nothing
            }


            world.write_model(@player);
            world.write_model(@game_state);
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"di")
        }
    }
}