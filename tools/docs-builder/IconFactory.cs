
using System;
using System.Drawing;
using System.Drawing.Drawing2D;

namespace EduFrameworkDocsBuilder;

public static class IconFactory
{
    public static Bitmap Create(string name, Color color, int size = 20)
    {
        var bitmap = new Bitmap(size, size);

        using var g = Graphics.FromImage(bitmap);
        g.SmoothingMode = SmoothingMode.AntiAlias;
        g.Clear(Color.Transparent);

        float s = size / 24f;
        g.ScaleTransform(s, s);

        using var pen = new Pen(color, 2.1f)
        {
            StartCap = LineCap.Round,
            EndCap = LineCap.Round,
            LineJoin = LineJoin.Round
        };

        using var brush = new SolidBrush(color);

        switch (name.ToLowerInvariant())
        {
            case "play":
                g.FillPolygon(brush, new[]
                {
                    new PointF(7, 4),
                    new PointF(20, 12),
                    new PointF(7, 20)
                });
                break;

            case "refresh":
                g.DrawArc(pen, 4, 4, 16, 16, 40, 285);
                g.DrawLine(pen, 19, 5, 20, 11);
                g.DrawLine(pen, 20, 11, 14, 10);
                break;

            case "trash":
                g.DrawLine(pen, 4, 7, 20, 7);
                g.DrawLine(pen, 9, 4, 15, 4);
                g.DrawLine(pen, 7, 7, 8, 20);
                g.DrawLine(pen, 17, 7, 16, 20);
                g.DrawLine(pen, 8, 20, 16, 20);
                g.DrawLine(pen, 10, 10, 10, 17);
                g.DrawLine(pen, 14, 10, 14, 17);
                break;

            case "layers":
                g.DrawRectangle(pen, 4, 4, 12, 12);
                g.DrawLine(pen, 9, 20, 20, 20);
                g.DrawLine(pen, 20, 20, 20, 9);
                break;

            case "watch":
                g.DrawEllipse(pen, 3, 3, 18, 18);
                g.DrawLine(pen, 12, 7, 12, 12);
                g.DrawLine(pen, 12, 12, 16, 14);
                break;

            case "stop":
                g.FillRectangle(brush, 6, 6, 12, 12);
                break;

            case "source":
                g.DrawLine(pen, 9, 6, 4, 12);
                g.DrawLine(pen, 4, 12, 9, 18);
                g.DrawLine(pen, 15, 6, 20, 12);
                g.DrawLine(pen, 20, 12, 15, 18);
                g.DrawLine(pen, 14, 4, 10, 20);
                break;

            case "pdf":
                g.DrawRectangle(pen, 5, 3, 14, 18);
                g.DrawLine(pen, 9, 9, 15, 9);
                g.DrawLine(pen, 9, 13, 15, 13);
                g.DrawLine(pen, 9, 17, 13, 17);
                break;

            case "folder":
                g.DrawLine(pen, 3, 8, 3, 20);
                g.DrawLine(pen, 3, 20, 21, 20);
                g.DrawLine(pen, 21, 20, 21, 8);
                g.DrawLine(pen, 3, 8, 21, 8);
                g.DrawLine(pen, 3, 8, 3, 5);
                g.DrawLine(pen, 3, 5, 10, 5);
                g.DrawLine(pen, 10, 5, 12, 8);
                break;

            case "help":
                g.DrawEllipse(pen, 3, 3, 18, 18);
                g.DrawArc(pen, 8, 6, 8, 8, 190, 240);
                g.FillEllipse(brush, 11, 17, 2, 2);
                break;

            case "terminal":
                g.DrawRoundedRectangle(
                    pen,
                    new Rectangle(2, 4, 20, 16),
                    new Size(3, 3)
                );

                g.DrawLine(pen, 6, 9, 10, 12);
                g.DrawLine(pen, 10, 12, 6, 15);
                g.DrawLine(pen, 12, 16, 18, 16);
                break;

            case "check":
                g.DrawEllipse(pen, 3, 3, 18, 18);
                g.DrawLine(pen, 7, 12, 11, 16);
                g.DrawLine(pen, 11, 16, 17, 8);
                break;

            default:
                g.FillEllipse(brush, 8, 8, 8, 8);
                break;
        }

        return bitmap;
    }
}
