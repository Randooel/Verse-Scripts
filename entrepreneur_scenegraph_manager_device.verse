using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/SceneGraph }
using { /UnrealEngine.com }
using { /Verse.org/SpatialMath }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Colors }
using {Meshes}

item_enum<public> := enum:
    Vazio # id 0
    Coxinha # id 1
    OvoRosa # id 2
    Sanduiche # id 3
    Coco # id Sarah Mattos from Brazil
    

    
GetItemSceneGraph<public>(Item:item_enum):entity =
     case(Item):
        item_enum.Coxinha => return NewEntityCox : P_Coxinha := P_Coxinha{}
        item_enum.OvoRosa => return NewEntityOVO : P_OvoRosa := P_OvoRosa{}
        item_enum.Sanduiche => return NewEntitySan : P_Sanduiche := P_Sanduiche{}
        
        _=> return Default : P_Coxinha := P_Coxinha{}

        

scenegraph_manager_device<public> := class(creative_device):

    @editable
    InputItem : input_trigger_device = input_trigger_device{}

    @editable
    InputItemReachMax : input_trigger_device = input_trigger_device{}

    @editable
    InputItemReachMin : input_trigger_device = input_trigger_device{}

    var Reach : float = 2000.0
    var MaxRange : float =6000.0
    var MinRange : float =500.0
    var CurrentItem : item_enum = item_enum.Coxinha
    var StopMoveItem : logic = true

    

    OnBegin<override>()<suspends>:void=
        InputItem.PressedEvent.Subscribe(StopItemMove)
        InputItemReachMax.PressedEvent.Subscribe(ChangeMaxReachMoveItem)
        InputItemReachMin.PressedEvent.Subscribe(ChangeMinReachMoveItem)
        Sleep(2.0)
       

    StopItemMove(Agent : agent):void=
        if(not StopMoveItem?):
            set StopMoveItem = true
        else:
            set StopMoveItem = false

            #so vai spawnar uma vez. depois de mudar o CurretItem ele vai instanciar apenas um desse objeto.
            if(CurrentItem <> item_enum.Vazio):
                spawn. LoopEntity(TrySpawnItemPrefab(Agent,CurrentItem),Agent)
            set CurrentItem = item_enum.Vazio
            # Print("Item atual: ")

    ChangeMaxReachMoveItem(Agent : agent):void=
        if(Reach<MaxRange):
            set Reach += 100.0

    ChangeMinReachMoveItem(Agent : agent):void=
        if(Reach>MinRange):
            set Reach -= 100.0

            
    TrySpawnItemPrefab(Player:agent, Item:item_enum):entity =
        Entity := GetItemSceneGraph(Item)
        if:
            FC := Player.GetFortCharacter[]
            FC.IsActive[]
        then:
            ConvertPosition := Temporary.SpatialMath.FromVector3(FC.GetTransform().Translation)
            TransformSlot := (/Verse.org/SpatialMath:)transform:
                Translation := ConvertPosition +  (/Verse.org/SpatialMath:)vector3{Left := 0.0, Up := 100.0, Forward := 0.0}
                Scale := (/Verse.org/SpatialMath:)vector3{Left := 2.0, Up := 2.0, Forward := 2.0}

            Entity.SetGlobalTransform(TransformSlot)
            Debug := debug_draw{}

        SimulateEntity(Self,Entity)
        return  Entity

    LoopEntity(Entity:entity, Player : agent)<suspends>:void=
        if:
            FC := Player.GetFortCharacter[]
            FC.IsActive[]
        then:
            
            Debug := debug_draw{}
            loop:
                if(StopMoveItem?):
                    break
                ViewRotation := FC.GetViewRotation()
                PlayerLocation := FC.GetTransform().Translation
                Forward := ViewRotation.GetLocalForward()
                EndLocation := PlayerLocation + (Forward * Reach)

                Debug.DrawLine of:
                    PlayerLocation,
                    EndLocation,
                    ?Color := NamedColors.Red,
                    ?Thickness := 5.0,
                    ?DrawDurationPolicy := debug_draw_duration_policy.FiniteDuration,
                    ?Duration := 0.1

                ConvertPosition := FromVector3(EndLocation)

                TransformSlot := (/Verse.org/SpatialMath:)transform:
                    Translation := ConvertPosition
                    Scale := (/Verse.org/SpatialMath:)vector3{Left := 1.0, Up := 1.0, Forward := 1.0} 

                Entity.SetGlobalTransform(TransformSlot)

                Sleep(0.1)



     