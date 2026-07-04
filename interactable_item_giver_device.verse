
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
using {Meshes}


# IPC: Ao adicionar novos prefabs, alterar o valor máximo da chamada de SetRandomItem > GetRandomItem()
GetItemIDSceneGraph<public>(ItemID : int):entity =
    case(ItemID):

       0 => return NewEntityCox : P_Coxinha := P_Coxinha{}
       1 => return NewEntityOvo : P_OvoRosa := P_OvoRosa{}
       2 => return NewEntitySan : P_Sanduiche := P_Sanduiche{}
       3 => return NewEntityCoc : P_Coco := P_Coco{}
       4 => return NewEntityBal : P_Balao := P_Balao{}
       5 => return NewEntityBom : P_Bomba := P_Bomba{}
       6 => return NewEntityCad : P_CadeiraPlastica := P_CadeiraPlastica{}
       7 => return NewEntityCap : P_Capivara := P_Capivara{}
       8 => return NewEntityEsc : P_Escada := P_Escada{}
       9 => return NewEntityEsp : P_Espinho := P_Espinho{}
       10 => return NewEntityGua : P_GuardaSol := P_GuardaSol{}
       11 => return NewEntityPed : P_Pedra := P_Pedra{}
       12 => return NewEntityPin : P_PinBall := P_PinBall {}
       13 => return NewEntityPla : P_Plataforma := P_Plataforma{}
       14 => return NewEntityPlaG : P_PlataformaGiratoria := P_PlataformaGiratoria{}
       15 => return NewEntityTac : P_TacoDeBilhar := P_TacoDeBilhar{}
       16 => return NewEntityVen : P_Ventilador := P_Ventilador{}
       
       _=> return Default : P_Coxinha := P_Coxinha{}


interactable_item_giver_device := class(creative_device):

    var CurrentItem : entity = entity{}
    var CreatedItems : []entity = array{}

    # Inputs de reach dos itens
    @editable InputItemReachMin : input_trigger_device = input_trigger_device{}
    @editable InputItemReachMax : input_trigger_device = input_trigger_device{}

    @editable InputDropItem : input_trigger_device = input_trigger_device{}
    

    # DEVICE REFERENCES
    @editable SpawnDevice : item_granter_device = item_granter_device{} # Usado APENAS como transform para spawnar os itens
    @editable Button : button_device = button_device{}
    #TODO: Pegar a duração da fase de coleta de itens e adicioná-la à variável "Tempo de Interação" do botão referenciado
    #OU Colocar uma parede (visível ou não) na seção com instâncias de this.class
    # /DEVICE REFERENCES



    # FUNCTIONS
    SetRandomItem():void= # FUNCIONANDO
        RandomID : int = GetRandomInt(0,16) # PRECISA ser referente ao número de elementos no ENUM GLOBAL de itens
        set CurrentItem = GetItemIDSceneGraph(RandomID)
        Print("{RandomID}");

        SpawnItemPrefab()
        set CreatedItems += array.  CurrentItem # Adiciona o item criado no array de itens criados
        ToggleCollidable(false)

        #GetSimulation().AddEntity(SpawnItemPrefab())

    SpawnItemPrefab():entity = # FUNCIONANDO
        ConvertPosition := Temporary.SpatialMath.FromVector3(SpawnDevice.GetTransform().Translation)
        TransformSlot := (/Verse.org/SpatialMath:)transform:
            Translation := ConvertPosition + (/Verse.org/SpatialMath:)vector3{Left := 0.0, Up := 0.0, Forward := 0.0}
            Scale := CurrentItem.GetGlobalTransform().Scale * (/Verse.org/SpatialMath:)vector3{Left := 0.5, Up := 0.5, Forward := 0.5}

        Print("Posicao: {TransformSlot.Translation}, Scale: {TransformSlot.Scale}")
        
        CurrentItem.SetGlobalTransform(TransformSlot) # Aplica a posição ao CurrentItem
        SimulateEntity(Self, CurrentItem) # Spawna a entidade
        return  CurrentItem

    ToggleCollidable(NewValue : logic):void=
        if(MeshComponent := CurrentItem.GetComponent[mesh_component]):
            set MeshComponent.Collidable = NewValue


    CheckPlayerCarrying(CheckAgent : agent)<transacts>:logic=
        Print("CheckIf")
        for(Item : CreatedItems):
            if(C := Item.GetComponent[prefab_items_behaviour]):
                return C.CheckPlayer(CheckAgent)
        return false


    GiveAgentItem(Agent : agent):void=
        Print("BUTON PRESSED!!!")
        if(not CheckPlayerCarrying(Agent)?):
            if(PrefabBehaviour := CurrentItem.GetComponent[prefab_items_behaviour]):
                PrefabBehaviour.ToggleFollowPlayer(true, Agent) # Permite que o loop comece
                # TODO: Passar agente para prefab_items_behaviour
                SetRandomItem() # TODO: Resetar valor de CurrentItem
        else:
             Print("Jogador ja esta segurando um item! (Hoje NAO!)")
        

    ReachMinMoveItem(Agent : agent):void=
        Print("ReachMinMoveItem")
        for(Item : CreatedItems):
            if(C := Item.GetComponent[prefab_items_behaviour]):
                C.ChangeMinReachMoveItem(Agent)


    ReachMaxMoveItem(Agent : agent):void=
        Print("ReachMaxMoveItem")
        for(Item:CreatedItems):
            if(C := Item.GetComponent[prefab_items_behaviour]):
                C.ChangeMaxReachMoveItem(Agent)

    DropItem(Agent : agent):void=
        Print("Drop Item")
        for(Item : CreatedItems):
            if(C := Item.GetComponent[prefab_items_behaviour]):
                C.DropItem(Agent)
                ToggleCollidable(true)


    OnBegin<override>()<suspends>:void= # FUNCIONANDO
        # Quando receber interação: Chama GiveAgentItem e passa qual jogador (Agent) ativou
        Button.InteractedWithEvent.Subscribe(GiveAgentItem) # OBS: InteractedWithEvent detecta Agent automaticamente

        # Inputs
        InputItemReachMin.PressedEvent.Subscribe(ReachMinMoveItem)
        InputItemReachMax.PressedEvent.Subscribe(ReachMaxMoveItem)
        
        InputDropItem.PressedEvent.Subscribe(DropItem)

        # Item setup
        SetRandomItem() #Define que item será spawnado

    # /FUNCTION