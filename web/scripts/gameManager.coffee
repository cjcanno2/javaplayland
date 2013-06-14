debugging = true
log = (mesg) ->  console.log mesg if debugging


class window.GameManager
    constructor: (@environment) ->
        @config = @environment.description
        if not @config.editor?
            @config.editor = {}
        if not @config.code?
            @config.code = {}

        if not @config.editor.buttons?
            @config.editor.buttons = ['switchUp', 'switchDown',
                'deleteLine', 'insertButtons']
        if not @config.editor.commands?
            @config.editor.commands = {
                    go: {
                        inputs: 1,
                        maxUses: 3
                    },
                    turnRight: {
                        inputs: 0,
                        maxUses: 2
                    },
                    turn: {
                        inputs: 2,
                        maxUses: 3
                    }
                }

        if not @config.code.prefix?
            @config.code.prefix = """
                public class Student {
                public static void main(String[] args) {\n
                """
        if not @config.code.initial?
            @config.code.initial = """
                go(15);
                turnRight();
                turn(__, __);
                go(2);
                """
        if not @config.code.postfix?
            @config.code.postfix = '}\n}'

        @editorDiv = 'codeEditor'
        @visualDiv = 'gameVisual'
        @setUpGame()

    setUpGame: ->
        ###
            Sets up everything for the game to run.
        ###
        @gameDiv = jQuery @environment.gamediv
        @gameDiv.append "<div id=\"#{@editorDiv}\" class=\"code_editor\"></div>"
        @gameDiv.append '<button id="compileAndRun">Go</button>'
        @gameDiv.append "<div id=\"#{@visualDiv}\" class=\"game_visual\"></div>"

        @codeEditor = new EditorManager @editorDiv, @config.editor, @config.code
        @interpreter = new CodeInterpreter @config.editor.commands

        @environment.visualMaster.container.id = @visualDiv
        @visual = new GameVisual @environment.visualMaster, @environment.frameRate
        @addEventListeners()
        return

    startGame: ->
        @config.visual.characters.protagonist.x = @config.game.startpos[0] - 1
        @config.visual.characters.protagonist.y = @config.game.startpos[1] - 1
        @visual.startGame @config.visual
        @gameState = new MapGameState @config.game, @visual, @config.visual.characters
        @commandMap = new MapGameCommands @gameState
        return

    finishGame: ->
        @codeEditor = null
        @interpreter = null
        @visual = null
        @gameDiv.empty()
        return

    addEventListeners: ->
        jQuery('#compileAndRun').click @runStudentCode
        return

    runStudentCode: =>
        @interpreter.scanText @codeEditor.getStudentCode()
        @interpreter.executeCommands @commandMap
        return

class MapGameState
    #<--DIRECTIONS-->
    #       ^
    #       0
    #   < 3 4 1 >
    #       2
    #       v
    constructor: (@config, @gameVisual, characterLoadconfig) ->
        # @config ?= { x: 4, y: 4, direction: 0, maxX:9, maxY:9, traps: [[2,4],[9,9]], targets: [[5,5]], targetCount : 0}
        @protagonist = {
            x: @config.startpos[0],
            y: @config.startpos[1],
            dir: if @config.direction? then @config.direction else 1,
            index: 0
        }
        @target = {
            x: @config.targetpos[0]
            y: @config.targetpos[1]
        }
        @gameVisual.charFace @protagonist.index, @protagonist.dir
        return

    # checkLocationOrThrow: ->
    #     @badLocation = true unless (0<= gameState.x <= gameState.maxX && 0 <= gameState.y <= gameState.maxY)
    #     if not gameState.traps
    #         return

    #     for [badx, bady] in gameState.traps
    #         if (gameState.x == badx && gameState.y == bady)
    #             @badLocation = true
    #     throw new BadLocation() if @badLocation
    #     return

    move: (steps) ->
        # Bits are more fun that lookup tables or a switch
        # sign is positive 1 for North00, East01, and -1 for South10, West11
        [sign, isEastOrWest] = [1  - (@protagonist.dir & 2), @protagonist.dir & 1]
        @protagonist.x += sign if isEastOrWest
        @protagonist.y += sign unless isEastOrWest

        if @protagonist.x == @target.x and @protagonist.y == @target.y
            alert "Victory" # Do something else here.
        @gameVisual.gridMove @protagonist.index, steps
        return

    turnRight: ->
        @turn (@protagonist.dir + 1) % 4
        return

    turnLeft: ->
        @turn (@protagonist.dir + 3) % 4
        return

    turn: (dir) ->
        @protagonist.dir = dir
        @gameVisual.charFace @protagonist.index, @protagonist.dir
        return

class MapGameCommands
    constructor: (@gameState) ->
        return

    go: (steps) =>
        steps = 1 if steps is undefined
        log "Go #{steps} steps."
        @gameState.move steps

    turn: (dir) =>
        log "turn '#{dir}'"
        return if dir is undefined
        d = $.inArray(dir, ['N','E','S','W'])
        if d >= 0
            @gameState.turn d
        else
            d = $.inArray(dir, ['North','East','South','West'])
            if d >= 0
                @gameState.turn d
            else
                @gameState.turn (4 + dir % 4) % 4
        return

    turnRight: =>
        log "turnRight"
        @gameState.turnRight()
        return

    turnLeft: =>
        log "turnLeft"
        @gameState.turnLeft()
        return

    turnAndGo: (direction, steps) =>
        log "turnAndGo #{direction} #{steps}"
        @turn direction
        @go steps
        return

    goNorth: (steps) => @turnAndGo 0, steps
    goEast:  (steps) => @turnAndGo 1, steps
    goWest:  (steps) => @turnAndGo 2, steps
    goSouth: (steps) => @turnAndGo 3, steps

    # used in sequence4
    mysteryA: => @goEast 4
    mysteryB: => @goSouth 1
    mysteryC: => @goWest 2