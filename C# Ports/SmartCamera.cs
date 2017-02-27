namespace CameraSharp
{
    using System;

    using LeagueSharp;
    using LeagueSharp.Common;

    internal class Program
    {
        private static Menu menu { get; set; }

        private static MenuItem ExtendedZoom { get; set; }

        private static MenuItem SmoothMove { get; set; }

        private static void Main(string[] args)
        {
            CustomEvents.Game.OnGameLoad += e => { Utility.DelayAction.Add(5000, OnGameLoad); };
        }

        private static void MoveSmooth(EventArgs args)
        {
            var position = ObjectManager.Player.Position;
            var distance = Camera.Position.Distance(position);

            if (distance <= 1)
            {
                return;
            }

            var speed = Math.Max(0.2f, Math.Min(20, distance * 0.0007f * 20));
            var direction = (position - Camera.Position).Normalized() * speed;

            Camera.Position = direction + Camera.Position;
        }

        private static void OnGameLoad()
        {
            menu = new Menu("Camera#", "camera", true);

            ExtendedZoom = menu.AddItem(new MenuItem("extendedzoom", "Extended Zoom").SetValue(false));
            ExtendedZoom.ValueChanged += (sender, e) =>
            {
                Camera.ExtendedZoom = e.GetNewValue<bool>();
            };

            SmoothMove = menu.AddItem(new MenuItem("movesmooth", "Smooth Move").SetValue(false));
            SmoothMove.ValueChanged += (sender, e) =>
            {
                if (e.GetNewValue<bool>())
                {
                    Game.OnUpdate += MoveSmooth;
                }
                else
                {
                    Game.OnUpdate -= MoveSmooth;
                }
            };

            menu.AddToMainMenu();

            if (ExtendedZoom.GetValue<bool>())
            {
                Camera.ExtendedZoom = true;
            }

            if (SmoothMove.GetValue<bool>())
            {
                Game.OnUpdate += MoveSmooth;
            }
        }
    }
}