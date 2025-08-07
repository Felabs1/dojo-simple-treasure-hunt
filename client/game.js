const ACTION_CONTRACT = 'di-actions';
const PLAYER_MODEL = 'di-Player';
const MAPCELL_MODEL = 'di-MapCell';
const GAMESTATE_MODEL = 'di-GameState';

function updateFromEntityData(entity) {
  if (entity.models) {
    if (entity.models[PLAYER_MODEL]) {
      const player = entity.models[PLAYER_MODEL];
      // A FUNCTION TO UPDATE POSITION DISPLAY LATER
      updatePositionDisplay(player.x.value, player.y.value);
      updateEnergyDisplay(player.energy.value);
      updateScoreDisplay(player.score.value);
    }

    if (entity.models[GAMESTATE_MODEL]) {
      const remainingTreasures = entity.models[GAMESTATE_MODEL].treasures_left.value;
      updateTreasureDisplay(remainingTreasures);
    }
  }
}

function updatePositionDisplay(x, y) {
  const positionDisplay = document.getElementById('position-display');
  if (positionDisplay) {
    positionDisplay.textContent = `Position: (${x}, ${y})`;
  }

  // Remove old highlight
  document.querySelectorAll('.cube').forEach((cube) => cube.classList.remove('active'));

  // Highlight the cube at (x, y)
  const activeCube = document.querySelector(`.cube[data-x="${x}"][data-y="${y}"]`);
  if (activeCube) {
    activeCube.classList.add('active');
  }
}

function updateEnergyDisplay(energy) {
  const energyDisplay = document.getElementById('energy-display');
  if (energyDisplay) {
    energyDisplay.textContent = `energy: ${energy}`;
  }
}

function updateScoreDisplay(score) {
  const scoreDisplay = document.getElementById('score-display');
  if (scoreDisplay) {
    scoreDisplay.textContent = `score ${score}`;
  }
}

function updateTreasureDisplay(remainingTreasures) {
  const treasureDisplay = document.getElementById('treasure-display');
  if (treasureDisplay) {
    treasureDisplay.textContent = `Treasures remaining ${remainingTreasures}`;
  }
}

// updatePositionDisplay(0, 0);

function initGame(account, manifest) {
  document.getElementById('north').onclick = async () => {
    await move(account, manifest, 'north');
  };

  document.getElementById('south').onclick = async () => {
    await move(account, manifest, 'south');
  };

  document.getElementById('east').onclick = async () => {
    await move(account, manifest, 'east');
  };

  document.getElementById('west').onclick = async () => {
    await move(account, manifest, 'west');
  };

  document.getElementById('spawn-button').onclick = async () => {
    await spawn(account, manifest);

    document.getElementById('north').disabled = false;
    document.getElementById('south').disabled = false;
    document.getElementById('east').disabled = false;
    document.getElementById('west').disabled = false;
  };
}

async function spawn(account, manifest) {
  const tx = await account.execute({
    contractAddress: manifest.contracts.find((contract) => contract.tag === ACTION_CONTRACT)
      .address,
    entrypoint: 'spawn',
    calldata: [],
  });

  console.log('game started: ', tx);
}

async function move(account, manifest, direction) {
  let calldata;

  // cairo serialization using various index to determine the direction
  switch (direction) {
    case 'north':
      calldata = ['0'];
      break;
    case 'south':
      calldata = ['1'];
      break;
    case 'east':
      calldata = ['2'];
      break;
    case 'west':
      calldata = ['3'];
      break;
  }

  const tx = await account.execute({
    contractAddress: manifest.contracts.find((contract) => contract.tag === ACTION_CONTRACT)
      .address,
    entrypoint: 'move_player',
    calldata: calldata,
  });

  console.log('Transaction sent', tx);
}

export { initGame, updateFromEntityData };
