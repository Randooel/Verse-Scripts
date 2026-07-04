using { /Verse.org }
using { /Verse.org/Native }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }

CollectableItem<public> := class<final_super>(component):

    @editable
    var WasCollected : logic = false
  
    # Void Start
    OnBeginSimulation<override>():void =
        #(super:)OnBeginSimulation()

        # TODO: Place logic to run when the component starts simulating here
        Print("OnBeginSimulation")

    OnSimulate<override>()<suspends>:void =
        # TODO: Place simple suspends logic to run for this component here
        Print("OnSimulate")

        