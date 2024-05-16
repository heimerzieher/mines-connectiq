using Toybox.Timer;

class MinesEngine
{
    private var field;

    private var cursor_pos;

    private var game_status;

    private var timer;

    private var seconds_count;

    public function initialize(s_field, n_mines)
    {
        field = new Field(s_field, n_mines);

        cursor_pos = new [2];

        cursor_pos[0] = 0;
        cursor_pos[1] = 0;

        game_status = STATUS_ACTIVE;

        seconds_count = 0;

        timer = new Timer.Timer();
        timer.start(method(:timerCallback)  as Method() as Void, 1000, true);
    }

    public function timerCallback() 
    {
        if(game_status == STATUS_ACTIVE)
        {
            seconds_count += 1;
            WatchUi.requestUpdate();
        }

        else
        {
            timer.stop();
        }

    }

    public function stop()
    {
        game_status = STATUS_INACTIVE;
        timer.stop(); //avoid timer errors
    }


    public function loadState(size, c_cells, c_cellsdisc, seconds_elapsed, status)
    {
        cursor_pos[0] = 0;
        cursor_pos[1] = 0;

        field.loadState(size, c_cells, c_cellsdisc);

        game_status = status;

        seconds_count = seconds_elapsed;

    }

    public function getFieldSize()
    {
        return field.getSize();
    }

    public function getCell(x, y)
    {
        return field.getDiscoveredCell(x, y);
    }

    public function setFlag(x,y)
    {
        field.setFlag(x,y);
    }

    public function discoverCell(x, y)
    {
        field.discoverCell(x, y);

        if(field.getDiscoveredCell(x, y) == CELL_MINE)
        {
            game_status = STATUS_LOST;
            field.uncover();
        }

        //check win condition
        else 
        {
            if(field.checkWinCondition())
            {
                game_status = STATUS_WON;
                field.uncover();
            }
        }
    }

    public function update()
    {   
        //complete unfinished discover work, we cannot do this recurisvely because the available space on the stack is too small (otherwise stack overflow)
        //due to hardware restrictions we discover at maximum 10 cells per call (otherwise "Code Executed Too Long" error)
        var counter = 0;

        for (var x  = 0; x < field.getSize(); x++)
        {
            for (var y = 0; y < field.getSize(); y++)
            {
                if((field.getDiscoveredCell(x, y) == CELL_TO_DISCOVER)&&(counter < 10))
                {
                    field.discoverCell(x, y);
                    // System.println("triggered discovered cell");
                    counter++;
                }
            }
        }

        // System.println("update");
    }

    public function cellExists(x,y)
    {
        return field.cellExists(x, y);
    }

    public function setCursor(x,y)
    {
        cursor_pos[0] = x;
        cursor_pos[1] = y;
    }

    public function getCursor()
    {
        return cursor_pos;
    }

    public function setStatus(status)
    {
        game_status = status;
    }

    public function getStatus()
    {
        return game_status;
    }

    public function getField()
    {
        return field;
    }

    public function getSecondsElapsed()
    {
        return seconds_count;
    }
}

class Field
{
    //this is a flat array
    private var cells;

    private var discovered_cells;

    private var size;

    public function initialize(s_field, n_mines)
    {
        size = s_field;

        cells = new [size*size];

        discovered_cells = new [size*size];

        // var prob_mine = (n_mines.toFloat()/(size*size).toFloat())*100.0f;

        // System.println(prob_mine);

        for (var i = 0; i < size*size; i++)
        {
            // if(Math.rand() % 100 < prob_mine)
            // {
            //     cells[i] = CELL_MINE;
            // }

            // else 
            // {
            //     cells[i] = CELL_EMPTY;
            // }

            cells[i] = CELL_EMPTY;
            
            discovered_cells[i] = CELL_UNDISCOVERED;
        }

        for (var i = 0; i < n_mines; i++)
        {
            var c = (Math.rand() % (size*size)).toNumber();
            cells[c] = CELL_MINE;
        }

        for (var x  = 0; x < size; x++)
        {
            for (var y = 0; y < size; y++)
            {
                if (getCell(x,y) == CELL_MINE)
                {
                    for (var i = -1; i <= 1; i++)
                    {
                        for (var j = -1; j <= 1; j++)
                        {
                            if(cellExists(x+i,y+j))
                            {
                                if((getCell(x+i,y+j) != CELL_MINE) && (i != 0 || j != 0))
                                {
                                    setCell(x+i,y+j, getCell(x+i,y+j) + 1);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public function checkWinCondition()
    {
        for (var i = 0; i < size*size; i++)
        {
            if((discovered_cells[i] == CELL_UNDISCOVERED || discovered_cells[i] == CELL_UNDISCOVERED_FLAGGED) && cells[i] != CELL_MINE)
            {
                return false;
            }
        }

        return true;
    }

    public function cellExists(x,y)
    {
        if(x >= 0 && x < size && y >= 0 && y < size)
        {
            return true;
        }

        else
        {
            return false;
        }
    }
    public function setFlag(x,y)
    {
        if(cellExists(x,y))
        {
            if(getDiscoveredCell(x,y) == CELL_UNDISCOVERED)
            {
                setDiscoveredCell(x,y, CELL_UNDISCOVERED_FLAGGED);
            }
            else if (getDiscoveredCell(x,y) == CELL_UNDISCOVERED_FLAGGED)
            {
                setDiscoveredCell(x,y, CELL_UNDISCOVERED);
            }
        }
    }


    //originally this should just resolve everythign recursivelyt by calling itself. However, more than 30 nested recursive calls lead to stack overflows.
    public function discoverCell(x,y)
    {
        if(cellExists(x,y))
        {
            if(getDiscoveredCell(x,y) == CELL_UNDISCOVERED || getDiscoveredCell(x,y) == CELL_UNDISCOVERED_FLAGGED || getDiscoveredCell(x,y) == CELL_TO_DISCOVER)
            {
                setDiscoveredCell(x,y,getCell(x,y));
            }
                if(getCell(x,y) == CELL_EMPTY)
                {
                    for (var i = -1; i <= 1; i++)
                    {
                        for (var j = -1; j <= 1; j++)
                        {
                            if(cellExists(x+i,y+j))
                            {
                                if((i != 0 || j != 0)&&((getDiscoveredCell(x+i,y+j) == CELL_UNDISCOVERED || getDiscoveredCell(x,y) == CELL_UNDISCOVERED_FLAGGED)))
                                {
                                    // setDiscoveredCell(x+i,y+j,getCell(x+i,y+j));
                                    setDiscoveredCell(x+i,y+j, CELL_TO_DISCOVER);
                                    // if(getCell(x+i,y+j) == CELL_EMPTY)
                                    // {
                                    //     
                                        //discoverCell(x+i,y+j);
                                    // }

                                    // // else 
                                    // // {
                                    //     setDiscoveredCell(x+i,y+j,getCell(x+i,y+j));
                                    // // }
                                }
                            }


                        }
                    }

                    // for (var i = -1; i <= 1; i++)
                    // {
                    //     for (var j = -1; j <= 1; j++)
                    //     {
                    //         if(cellExists(x+i,y+j))
                    //         {
                    //             if(getCell(x+i,y+j) == CELL_EMPTY)
                    //             {
                    //                 // if(getCell(x+i,y+j) == CELL_EMPTY)
                    //                 // {
                    //                 //     discoverCell(x+i,y+j);
                    //                 // }

                    //                 // else 
                    //                 // {
                    //                     // setDiscoveredCell(x+i,y+j,getCell(x+i,y+j));
                    //                 // }

                    //                 // discoverCell(x+i,y+j);
                    //             }
                    //         }
                    //     }
                    // }
                }
            
            
        }

        //System.print("discover cell triggered");
        WatchUi.requestUpdate();
    }

    public function uncover()
    {
        discovered_cells = cells;
    }

    public function loadState(s, c_cells, c_cellsdisc)
    {
        size = s;
        cells = c_cells;
        discovered_cells = c_cellsdisc;
    }

    public function getCell(x,y)
    {
        return cells[x + size*y];
    }

    public function setCell(x, y, val)
    {
        cells[x + size*y] = val;
    }

    public function getCells()
    {
        return cells;
    }

    public function setCells(c)
    {
        cells = c;
    }

    public function getDiscoveredCell(x,y)
    {
        return discovered_cells[x + size*y];
    }


    public function setDiscoveredCell(x, y, val)
    {
        discovered_cells[x + size*y] = val;
    }

    public function getDiscoveredCells()
    {
        return discovered_cells;
    }

    public function setDiscoveredCells(c)
    {
        discovered_cells = c;
    }

    public function getSize()
    {
        return size;
    }
}

enum
{   
    CELL_EMPTY = 0,
    CELL_1 = 1,
    CELL_2 = 2,
    CELL_3 = 3,
    CELL_4 = 4,
    CELL_5 = 5,
    CELL_6 = 6,
    CELL_7 = 7,
    CELL_8 = 8,
    CELL_MINE = 9,
    CELL_TO_DISCOVER = 66,
    CELL_UNDISCOVERED = 88,
    CELL_UNDISCOVERED_FLAGGED= 77
}

enum
{
  STATUS_ACTIVE = 0,
  STATUS_LOST = 1,
  STATUS_WON = 2,
  STATUS_INACTIVE

}