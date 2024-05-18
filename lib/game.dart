import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart';

class MainGame extends StatelessWidget {
  const MainGame({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: game,
      overlayBuilderMap: const {
        "PauseMenu": _pauseMenuBuilder,
      },
    );
  }
}

Widget _pauseMenuBuilder(BuildContext buildContext, Game game) {
  return Center(
    child: Stack(
      children: [
        Container(color: Colors.black.withOpacity(.75)),
        Container(
            margin: EdgeInsets.symmetric(vertical: 225, horizontal: 50),
            padding: EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(25)),
                border: Border.all(color: Colors.white, width: 3)),
            child: Wrap(
              children: [
                Column(
                  children: [
                    Text(
                      game.stepCount >= maxSteps ? "You lose!" : "You win!",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 45,
                          decoration: TextDecoration.none),
                    ),
                    Padding(padding: EdgeInsets.all(10)),
                    Text(
                      "Level: " + currentLevel.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(20)),
                    Container(
                      width: 250,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          game.stepCount >= maxSteps ?
                          game.Restart() :
                              game.NextLevel();
                        },
                        child: Text(
                          game.stepCount >= maxSteps ? "Restart" : "NextLevel",
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightGreen),
                      ),
                    )
                  ],
                )
              ],
            )),
      ],
    ),
  );
}

Widget overlayBuilder() {
  return GameWidget<Game>(
    game: Game()..paused = true,
    overlayBuilderMap: const {
      'PauseMenu': _pauseMenuBuilder,
    },
    initialActiveOverlays: const ['PauseMenu'],
  );
}

Game game = Game();
Ball ball = Ball();
Arrow arrow = Arrow();
Flag flag = Flag(Vector2.zero());
Vector2 gravity = Vector2(0, 0);
bool ballIsSpawned = false;

double deltaTime = 0;

double pushForce = 1;

int currentLevel = 1;
int maxSteps = 4;

Levels levels = Levels();

TextComponent textComponent = TextComponent(
    text: "Level: " + currentLevel.toString(),
    anchor: Anchor.center,
    position: Vector2(game.canvasSize.x / 2, 50),
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 35,
      ),
    ));

class Game extends Forge2DGame with DragCallbacks, TapCallbacks {
  Vector2 startPoint = Vector2.zero();
  Vector2 endPoint = Vector2.zero();
  Vector2 direction = Vector2.zero();
  Vector2 force = Vector2.zero();
  double distance = 0;

  int stepCount = 0;

  bool canPush = true;

  SpriteComponent bg = SpriteComponent();

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    if(!canPush)
      return;

    startPoint = event.canvasPosition;

    arrow.setVisible(true);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    if(!canPush)
      return;

    endPoint = event.canvasPosition;
    distance = vectorDistance(startPoint, endPoint) / 2;
    direction = ((startPoint - endPoint) / 2).normalized();
    force = ((direction * distance) * pushForce);

    arrow.setTransform(ball.body.position, direction, distance);
    //trajectory.updateDots(ball.position, force);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    if(!canPush || arrow.spr.opacity == 0)
      return;

    ball.push(force);
    arrow.setVisible(false);

    canPush = false;

    stepCount++;

  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if(ballIsSpawned){
      if(ball.body.linearVelocity.length < .4){
        canPush = true;
        if(stepCount >= maxSteps){
          OnEndGame();
        }
      }
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();


    game.camera.viewfinder.zoom = 25;

    world.gravity = gravity;
    world.physicsWorld.gravity = gravity;

    bg
      ..sprite = await loadSprite("background.png")
      ..size = Vector2(size.x, size.y)
    ;
    add(bg);
    add(textComponent);

    levels.init();

    world.addAll(levels.getLevel(currentLevel).getComponents());
    flag = levels.getLevel(currentLevel).getComponents()[0] as Flag;

    world.add(arrow);
    ball = Ball(initialPosition:Vector2(0, 12));
    world.add(ball);
    world.addAll(createBoundaries());
  }

  List<Component> createBoundaries() {
    final visibleRect = camera.visibleWorldRect;
    final topLeft = visibleRect.topLeft.toVector2();
    final topRight = visibleRect.topRight.toVector2();
    final bottomRight = visibleRect.bottomRight.toVector2();
    final bottomLeft = visibleRect.bottomLeft.toVector2();

    return [
      Wall(topLeft, topRight),
      Wall(topRight, bottomRight),
      Wall(bottomLeft, bottomRight),
      Wall(topLeft, bottomLeft),
    ];
  }

  void Restart(){
    stepCount = 0;

    overlays.remove('PauseMenu');
    resumeEngine();

    ball.body.linearVelocity = Vector2.zero();
    ball.body.setTransform(Vector2(0, 12), 0);
  }

  void NextLevel(){
    stepCount = 0;

    overlays.remove('PauseMenu');
    resumeEngine();


    currentLevel++;
    textComponent.text = "Level: " + currentLevel.toString();

    flag = levels.getLevel(currentLevel).getComponents()[0] as Flag;
    world.removeAll(levels.getLevel(currentLevel - 1).getComponents());
    world.addAll(levels.getLevel(currentLevel).getComponents());

    ball.body.linearVelocity = Vector2.zero();
    ball.body.setTransform(Vector2(0, 12), 0);
  }

  void OnEndGame() {
    overlays.add('PauseMenu');
    pauseEngine();
  }
}

class Arrow extends BodyComponent{

  SpriteComponent spr = SpriteComponent();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    priority = 3;
    final sprite = await game.loadSprite('arrow.png');
    spr = SpriteComponent(
      sprite: sprite,
      anchor: Anchor.bottomCenter,
      scale: Vector2.all(0.005),
    );
    add(spr);

    setVisible(false);
  }

  void setVisible(bool visible){
    spr.opacity = visible ? 1 : 0;
  }

  void setTransform(Vector2 pos, Vector2 dir, double distance){
    body.setTransform(pos, radians(lookAt(ball.position, ball.position + dir)));

    spr.scale = Vector2(0.005, 0.00025 * (distance / 2));
  }

  @override
  Body createBody() {
    FixtureDef fixtureDef = FixtureDef(CircleShape()..radius = 4, friction: .45, restitution: 0.35, density: 1, isSensor: true);
    BodyDef bodyDef = BodyDef(userData: this, position: Vector2.zero(), type: BodyType.kinematic);


    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

}

class Flag extends BodyComponent{

  Flag(Vector2 pos){
    startPos = pos;
  }

  Vector2 startPos = Vector2.zero();

  SpriteComponent spr = SpriteComponent();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    final sprite = await game.loadSprite('flag.png');
    spr = SpriteComponent(
      sprite: sprite,
      anchor: Anchor.bottomCenter,
      scale: Vector2.all(0.4),
      position: Vector2(0,1),
      priority: -1
    );
    add(spr);
    priority = -1;
  }

  @override
  Body createBody() {
    FixtureDef fixtureDef = FixtureDef(CircleShape()..radius = 1, isSensor: true);
    BodyDef bodyDef = BodyDef(userData: this, position: startPos, type: BodyType.static);


    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Ball extends BodyComponent with TapCallbacks, ContactCallbacks {
  Ball({Vector2? initialPosition})
      : super(
    fixtureDefs: [
      FixtureDef(
        CircleShape()..radius = .7,
        restitution: .5,
        friction: 0.2,
      ),
    ],
    bodyDef: BodyDef(
      linearDamping: .75,
      fixedRotation: true,
      position: initialPosition ?? Vector2.zero(),
      type: BodyType.dynamic,
    ),
  );

  void push(Vector2 dir){
    body.applyLinearImpulse(dir);
  }

  @override
  void onMount() {
    super.onMount();
    ballIsSpawned = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    deltaTime = dt;

    if(vectorDistance(ball.body.position, flag.body.position) < 1.5){
      ball.body.linearVelocity = Vector2.zero();
      game.OnEndGame();
    }
  }
}

class Wall extends BodyComponent {
  final Vector2 _start;
  final Vector2 _end;

  Wall(this._start, this._end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(_start, _end);
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(
      position: Vector2.zero(),
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Fence extends BodyComponent{

  Fence(Vector2 pos, double rot){
    startPos = pos;
    rotation = rot;
  }

  double rotation = 0;
  Vector2 startPos = Vector2.zero();

  SpriteComponent spr = SpriteComponent();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    final sprite = await game.loadSprite('fence.png');
    spr = SpriteComponent(
        sprite: sprite,
        anchor: Anchor.bottomCenter,
        scale: Vector2.all(0.2),
        position: Vector2(0,1)
    );
    add(spr);
  }

  @override
  Body createBody() {
    FixtureDef fixtureDef = FixtureDef(PolygonShape()..setAsBoxXY(4, 1.2));
    BodyDef bodyDef = BodyDef(userData: this, position: startPos, angle: radians(rotation), type: BodyType.static);


    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Tree extends BodyComponent{

  Tree(Vector2 pos, double rot){
    startPos = pos;
    rotation = rot;
  }

  double rotation = 0;
  Vector2 startPos = Vector2.zero();

  SpriteComponent spr = SpriteComponent();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    final sprite = await game.loadSprite('tree.png');
    spr = SpriteComponent(
        sprite: sprite,
        anchor: Anchor.bottomCenter,
        scale: Vector2.all(0.2),
        position: Vector2(0,2)
    );
    add(spr);
  }

  @override
  Body createBody() {
    FixtureDef fixtureDef = FixtureDef(PolygonShape()..setAsBoxXY(1.3, 2));
    BodyDef bodyDef = BodyDef(userData: this, position: startPos, angle: radians(rotation), type: BodyType.static);


    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Rock extends BodyComponent{

  Rock(Vector2 pos, double rot){
    startPos = pos;
    rotation = rot;
  }

  double rotation = 0;
  Vector2 startPos = Vector2.zero();

  SpriteComponent spr = SpriteComponent();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    final sprite = await game.loadSprite('rock.png');
    spr = SpriteComponent(
        sprite: sprite,
        anchor: Anchor.bottomCenter,
        scale: Vector2.all(0.2),
        position: Vector2(0,1)
    );
    add(spr);
  }

  @override
  Body createBody() {
    FixtureDef fixtureDef = FixtureDef(PolygonShape()..setAsBoxXY(1.3, 1.3));
    BodyDef bodyDef = BodyDef(userData: this, position: startPos, angle: radians(rotation), type: BodyType.static);


    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Plank extends BodyComponent{

  Plank(Vector2 pos, double rot){
    startPos = pos;
    rotation = rot;
  }

  double rotation = 0;
  Vector2 startPos = Vector2.zero();

  SpriteComponent spr = SpriteComponent();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    final sprite = await game.loadSprite('plank.png');
    spr = SpriteComponent(
        sprite: sprite,
        anchor: Anchor.bottomCenter,
        scale: Vector2.all(0.2),
        position: Vector2(0,1)
    );
    add(spr);
  }

  @override
  Body createBody() {
    FixtureDef fixtureDef = FixtureDef(PolygonShape()..setAsBoxXY(4, 1.2));
    BodyDef bodyDef = BodyDef(userData: this, position: startPos, angle: radians(rotation), type: BodyType.static);


    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Levels{

  List<Level> levels = [];

  void init(){
    List<Component> level1Comps = [
      Flag(Vector2(0, -5))
    ];
    List<Component> level2Comps = [
      Flag(Vector2(0, -5)),
      Fence(Vector2(0,-1), 0)
    ];
    List<Component> level3Comps = [
      Flag(Vector2(0, -7)),
      Tree(Vector2(0,0), 0),
      Fence(Vector2(5,0), 90),
      Fence(Vector2(-5,0), -90)
    ];
    List<Component> level4Comps = [
      Flag(Vector2(0, -7)),
      Fence(Vector2(4,1), 90),
      Fence(Vector2(-4,1), -90),
      Fence(Vector2(0,-4), 0),
      Rock(Vector2(6.5, 4), 0),
      Tree(Vector2(-4, -10), 0),
    ];
    List<Component> level5Comps = [
      Flag(Vector2(0, -7)),
      Tree(Vector2(0,4), 0),
      Tree(Vector2(5,-3), 0),
      Tree(Vector2(-5,-3), 0),
      Rock(Vector2(-2.8,-1.5), 0),
      Rock(Vector2(2.8,-1.5), 0),
    ];
    List<Component> level6Comps = [
      Flag(Vector2(0, -7)),
      Rock(Vector2(-5,-1.5), 0),
      Rock(Vector2(5,-3), 0),
      Rock(Vector2(-4,2.5), 0),
      Rock(Vector2(1,-5), 0),
      Rock(Vector2(4,2), 0),
      Tree(Vector2(4,7), 0),
      Tree(Vector2(-3.5,-7), 0),
      Fence(Vector2(1,0), 70),
    ];
    List<Component> level7Comps = [
      Flag(Vector2(0, 4)),
      Fence(Vector2(0, 6), 0),
      Fence(Vector2(4.5, 3), 90),
      Fence(Vector2(-4.5, 3), -90),

      Fence(Vector2(4.5, -5), 90),
      Fence(Vector2(-4.5, -5), -90),

      Tree(Vector2(0, -10), 0),
    ];
    List<Component> level8Comps = [
      Flag(Vector2(0, -7)),
      Fence(Vector2(0, 6), 90),

      Tree(Vector2(4, -6), 0),
      Tree(Vector2(-4, -6), 0),
      Fence(Vector2(0, -4), 0),
    ];

    levels.add(Level()..setComponents(level1Comps));
    levels.add(Level()..setComponents(level2Comps));
    levels.add(Level()..setComponents(level3Comps));
    levels.add(Level()..setComponents(level4Comps));
    levels.add(Level()..setComponents(level5Comps));
    levels.add(Level()..setComponents(level6Comps));
    levels.add(Level()..setComponents(level7Comps));
    levels.add(Level()..setComponents(level8Comps));
  }

  Level getLevel(int level){
    return levels[level-1];
  }
}

class Level{
  List<Component> comps = [];

  void setComponents(List<Component> c){
    comps = c;
  }

  List<Component> getComponents(){
    return comps;
  }
}

double lookAt(Vector2 a, Vector2 b) {
  Vector2 dir = a - b;
  return -degrees(atan2(dir.x, dir.y));
}

double vectorDistance(Vector2 v1, Vector2 v2) {
  return sqrt(pow(v1.x - v2.x, 2) + pow(v1.y - v2.y, 2));
}