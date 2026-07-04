using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/SceneGraph }
using { /UnrealEngine.com }
using { /Verse.org/SpatialMath }

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/SceneGraph }
using { /UnrealEngine.com }
using { /Verse.org/SpatialMath }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Colors }
using { /Verse.org/Random}
using { /Verse.org/Simulation }


# A Verse-authored component that can be added to entities
prefab_items_behaviour<public> := class<final_super>(component):

    var FollowPlayerBool : logic = false
    var ThisPlayer<public> : ?agent = false

    var Reach : float = 2000.0
    var MinRange : float = 500.0
    var MaxRange : float = 6000.0


    ToggleFollowPlayer<public>(NewValue : logic, Agent : agent):void =
        set FollowPlayerBool = NewValue
        set ThisPlayer = option. Agent
        spawn. FollowPlayer(Agent)        
        # Print("FollowPlayer bool == {?FollowPlayerBool}")


    FollowPlayer(Agent : agent)<suspends>:void=
        if(FC := Agent.GetFortCharacter[], FC.IsActive[]):
            loop: # Mini FixedUpdate()
                if(FollowPlayerBool = true):
                    # Pegando transform do jogador
                    PTranslation := Temporary.SpatialMath.FromVector3(FC.GetTransform().Translation)
                    ViewRotationForward := Temporary.SpatialMath.FromVector3(FC.GetViewRotation().GetLocalForward())
                    EndLocation := PTranslation + (ViewRotationForward * Reach)

                    # Convertendo Transform
                    TransformSlot := (/Verse.org/SpatialMath:)transform: # TODO: Add forward and up offset
                        Translation := EndLocation
                        Scale := Entity.GetGlobalTransform().Scale #* (/Verse.org/SpatialMath:)vector3{Left := 2.0, Up := 2.0, Forward := 2.0}
                    
                    # Aplicando transform ao item
                    Entity.SetGlobalTransform(TransformSlot)
                else break
                Sleep(0.1)
    

    DropItem(Agent : agent):void=
        if(MaybeAgent := ThisPlayer?):
            if(Agent = MaybeAgent):
                set FollowPlayerBool = false
                set ThisPlayer = false
                if(FA := Entity.GetComponent[Flip_Animation_Component]):
                    spawn. FA.AnimateEntity()

    CheckPlayer<public>(CheckAgent : agent)<transacts>:logic=
        if(MaybePlayer := ThisPlayer?):
            if(CheckAgent = MaybePlayer):
                return true
        return false

    ChangeMinReachMoveItem<public>(Agent : agent):void=
        Print("ChangeMinReachMoveItem")
        if(MaybeAgent := ThisPlayer?):
            if(Agent = MaybeAgent):
                Print("Agente confirmado!")
                if(Reach>MinRange):
                    set Reach -= 100.0


    ChangeMaxReachMoveItem<public>(Agent : agent):void=
        Print("ChangeMaxReachMoveItem")
        if(MaybeAgent := ThisPlayer?):
            if(Agent = MaybeAgent):
                Print("Agente confirmado!")
                if(Reach<MaxRange):
                    set Reach += 100.0


    # Runs when the component should start simulating in a running game.
    OnBeginSimulation<override>():void =
        Print("# TODO: Implementar debug do valor da var entity Item do script prefab_items_behaviour")

        
    OnSimulate<override>()<suspends>:void =
        # TODO: Place simple suspends logic to run for this component here
        Print("OnSimulate")

