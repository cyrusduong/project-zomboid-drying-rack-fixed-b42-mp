## 1. Foundation Setup
- [x] 1.1 Initialize project structure (Modular Architecture)
- [x] 1.2 Create mod.info file with B42 metadata
- [x] 1.3 Set up media/lua/{client,shared,tests} structure
- [x] 1.4 Migrate mod identity to DryingRackFixedB42MP

## 2. Core Implementation
- [x] 2.1 Implement `DryingRackUtils.lua` for entity detection
- [x] 2.2 Create unified `ISDryItemAction.lua` Timed Action
- [x] 2.3 Implement Leather Registry (`DryingRackData_Leather.lua`)
- [x] 2.4 Implement Plant Registry (`DryingRackData_Plants.lua`)

## 3. Context Menu Integration
- [x] 3.1 Implement `ISDryingRackMenu_Leather.lua` with size validation
- [x] 3.2 Implement `ISDryingRackMenu_Plants.lua` for herb racks
- [x] 3.3 Add "Dry All" functionality for bulk processing
- [x] 3.4 Handle player proximity and size mismatch feedback

## 4. Testing & Validation
- [x] 4.1 Create `DryingRackTests.lua` for modular logic
- [x] 4.2 Verify strict size matching for leather
- [x] 4.3 Verify herb rack detection and plant mapping
- [ ] 4.4 Perform final in-game MP validation (User Task)

## 5. Documentation & Metadata
- [x] 5.1 Update README.md with new features and structure
- [x] 5.2 Update workshop metadata (workshop.txt, workshop_build.vdf)
- [x] 5.3 Synchronize local installation via `install.sh`
