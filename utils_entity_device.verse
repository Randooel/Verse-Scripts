using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/SceneGraph }
using { /Fortnite.com/Characters }
using { /Verse.org/SpatialMath }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com }




SimulateEntity<public>(Device : creative_device, Entity: entity):void=
    if:
        SimulationEntity := Device.GetSimulationEntity[]
    then:
        Print("Simulate")
        SimulationEntity.AddEntities(array{Entity})

AttachEntityOnAgent<public>(Device : creative_device, Entity: entity, Agent:agent, ?OwnerSee : logic = true,?PosL : float = 0.0,?PosUP : float = 75.0, ?PosF : float = 0.0 ):void=
    SimulateEntity(Device, Entity)
    if(not OwnerSee?):
        #Players := GetPlayerExcept(Agent)
        #Entity.SetPresentableToPlayers(Players)
    if:
        FC := Agent.GetFortCharacter[]
    then:
        if:
            FortCharEntity := FC.GetEntity[]
        then:
            Entity.SetOrigin of entity_origin:
                Entity := FortCharEntity

    Entity.SetLocalTransform of (/Verse.org/SpatialMath:)transform:
        Translation := (/Verse.org/SpatialMath:)vector3{Left :=PosL, Up:=PosUP, Forward:=PosF}

RemoveEntityCompletely<public>(E : entity, ?BatchSize : int = 20, ?DelaySeconds : float = 0.05)<suspends>: void =
    var Stack : []entity = array{E}
    var Batch : int = BatchSize
    if (Batch <= 0):
        set Batch = 1
    var Counter : int = 0

    loop:
        if (Stack.Length = 0):
            break

        LastIdx := Stack.Length - 1
        var Current : ?entity = false
        if (LastIdx >= 0, Ent := Stack[LastIdx]):
            set Current = option{Ent}

        # Pop do topo da pilha sem slices pesadas
        var NewStack : []entity = array{}
        var Limit : int = Stack.Length - 1
        for (i := 0 .. Limit - 1):
            if (Item := Stack[i]):
                set NewStack = NewStack + array{Item}
        set Stack = NewStack

        if (Entity := Current?):
            for (Comp : Entity.GetComponents()):
                Comp.RemoveFromEntity

            for (Child : Entity.GetEntities()):
                set Stack = Stack + array{Child}

            if (Entity <> E):
                Entity.RemoveFromParent()

        set Counter = Counter + 1
        if (Counter >= Batch):
            if (DelaySeconds > 0.0):
                Sleep(DelaySeconds)
            set Counter = 0

    E.RemoveFromParent()

CreateEntity(Device : creative_device, Agent:agent):entity=
    if:
        FortChar := Agent.GetFortCharacter[]
        FortChar.IsActive[]
    then:
        InitialPosition :=FortChar.GetTransform().Translation
        
        InitialPositionOffset := Temporary.SpatialMath.vector3:
            X := InitialPosition.X + 200.0
            Y := InitialPosition.Y + 200.0
            Z := InitialPosition.Z + -80.0

        ConvertInitialPosition := FromVector3(InitialPositionOffset)

        UseRotation := FromRotation(FortChar.GetViewRotation())
        
        InitialTransform := (/Verse.org/SpatialMath:)transform:
            Translation := ConvertInitialPosition

        NE := entity{}
        var Comps : []component = array{}

        TransComp := transform_component:
            GlobalTransform := InitialTransform,
            Entity := NE
        set Comps += array{TransComp}

       <#  MeshComp := Meshes.Box1:
            Entity := NE
            Visible := true

        set Comps += array{MeshComp} #>

        

        NE.AddComponents(Comps)

        SimulateEntity(Device, NE)

        return NE

    return entity{}


 