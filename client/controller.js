import manifest from '../manifest_dev.json' assert { type: 'json' };

const actionsContract = manifest.contracts.find((contract) => contract.tag === 'di-actions');

const controllerOpts = {
  chains: [{ rpcUrl: 'http://localhost:5050' }],
  // "KATANA"
  defaultChainId: '0x4b4154414e41',
  policies: {
    contracts: {
      [actionsContract.address]: {
        name: 'Actions',
        description: 'Actions contract control player movement',
        methods: [
          {
            name: 'Spawn',
            entrypoint: 'spawn',
            description: 'spawn the player in the game',
          },
          {
            name: 'MovePlayer',
            entrypoint: 'move_player',
            description: 'move the player in the game',
          },
        ],
      },
    },
  },
};

export default controllerOpts;
