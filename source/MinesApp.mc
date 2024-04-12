import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class MinesApp extends Application.AppBase 
{

    public var engine;


    public var n_cells;
    public var n_mines;

    public var view;

    function initialize() 
    {
        AppBase.initialize();

        n_mines = Application.Properties.getValue("NumberMines");
        n_cells = Application.Properties.getValue("SizeField");


        engine = new MinesEngine(n_cells, n_mines);

        if(Application.Properties.getValue("SaveFieldSize") != 0 && Application.Properties.getValue("SaveFieldCells") != null && Application.Properties.getValue("SaveFieldDiscoveredCells") != null && Application.Properties.getValue("SaveSecondsElapsed") != null)
        {
            loadGame();
        }

        // engine.discoverCell(0, 0);
    }

    public function saveGame()
    {
        var field = engine.getField();

        Application.Properties.setValue("SaveFieldSize", field.getSize() as Number);
        Application.Properties.setValue("SaveFieldCells", field.getCells() as Array<Number>);
        Application.Properties.setValue("SaveFieldDiscoveredCells", field.getDiscoveredCells() as Array<Number>);
        Application.Properties.setValue("SaveSecondsElapsed", engine.getSecondsElapsed() as Number);
    }

    public function loadGame()
    {
        var size = Application.Properties.getValue("SaveFieldSize") as Number;
        var cells = Application.Properties.getValue("SaveFieldCells") as Array<Number>;
        var cells_disc = Application.Properties.getValue("SaveFieldDiscoveredCells") as Array<Number>;
        var secs_elapsed = Application.Properties.getValue("SaveSecondsElapsed") as Number;


        engine.loadState(size, cells, cells_disc, secs_elapsed);           
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void 
    {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void 
    {
        saveGame();
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? 
    {
        view = new MinesView();
        return [ view , new MinesDelegate() ] as Array<Views or InputDelegates>;
    }

}

function getApp() as MinesApp 
{
    return Application.getApp() as MinesApp;
}