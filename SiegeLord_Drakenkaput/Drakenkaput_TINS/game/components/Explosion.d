/*
Copyright 2012 Pavel Sountsov

This file is part of TINSEngine.

TINSEngine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

TINSEngine is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with TINSEngine.  If not, see <http://www.gnu.org/licenses/>.
*/
module game.components.Explosion;

import engine.MathTypes;
import engine.Config;
import engine.ComponentHolder;

import game.GameObject;
import game.components.Position;
import game.components.Collision;
import game.ParticleEmitter;

import tango.io.Stdout;
 
class CExplosion : CGameComponent
{	
	override
	void Load(CGameObject game_obj, CConfig config)
	{
		GameObject = game_obj;
		game_obj.Level.LogicEvent.Register(&Logic);
		game_obj.Level.DrawEvent.Register(&Draw, 5);
		
		auto level = game_obj.Level;
		
		Emitter = new CParticleEmitter(config.Get!(const(char)[])(ComponentName!(typeof(this)), "particle_emitter"), level.Game, level.ConfigManager, level.BitmapManager);
		Lifetime = config.Get!(float)(ComponentName!(typeof(this)), "lifetime", 0.5);
		
		Time = &game_obj.Level.Game.Time;
		
		WhenToDie = Time() + Lifetime;
	}
	
	override
	void Unload(CGameObject game_obj)
	{
		game_obj.Level.LogicEvent.UnRegister(&Logic);
		game_obj.Level.DrawEvent.UnRegister(&Draw);
	}

	void Logic(float dt)
	{
		if(Time() > WhenToDie)
			GameObject.Remove();
		
		Emitter.Logic(dt);
	}
	
	void Draw()
	{
		Emitter.Draw();
	}
	
	void Start(SVector2D pos, float theta)
	{
		Emitter.Position = pos;
		Emitter.Theta = theta;
	}
protected:
	CParticleEmitter Emitter;
	double delegate() Time;
	CGameObject GameObject;
	float Lifetime;
	float WhenToDie = float.infinity;
}
