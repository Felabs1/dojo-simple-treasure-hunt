use starknet::ContractAddress;
use core::num::traits::{SaturatingAdd, SaturatingSub};

#[derive(Serde, Copy, Drop, Introspect)]
pub enum Direction {
    // serialized as 0
    North,
    // serialized as 1
    South,
    // serialized as 2
    East,
    // serialized as 3
    West
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Player {
    #[key]
    pub playerId: ContractAddress,  // unique id for player
    pub x: u32,
    pub y: u32,
    pub energy: u32,
    pub score: u32,
}

// map cell model = to store the type of cell
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct MapCell {
    #[key]
    pub x: u32,
    #[key]
    pub y: u32,
    pub cell_type: felt252, // 0=empty 1=treasure 2=trap
}

// game state - stores total treasures left
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct GameState {
    #[key]
    pub playerId: ContractAddress,
    pub treasures_left: u32,
}

#[generate_trait]
pub impl PlayerImpl of PlayerTrait {
    fn apply_direction(ref self: Player, direction: Direction) {
        match direction {
            Direction::North => {self.y = self.y.saturating_sub(1)},
            Direction::South => {self.y = self.y.saturating_add(1)},
            Direction::East => {self.x = self.x.saturating_add(1)},
            Direction::West => {self.x = self.x.saturating_sub(1)}
        }
    }

    // fn ()
}

// #[generate_trait]
// pub impl MapCellImpl of MapCellTrait {
//     fn initialize_new_cell
// }