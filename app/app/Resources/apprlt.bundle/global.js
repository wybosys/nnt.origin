
function TouchManager(dom) {
    // 回调
    this.ontouchaction = null;

    // 是否正在拖动
    this.dragging = false;

    // 是否正在减速
    this.decelerating = false;
    
    var _this = this;
    var ptts = 0;
    var ptdrag = new THREE.Vector3();
    var disdrag = new THREE.Vector3();
    var init = function()
    {
        dom.addEventListener('mousedown', function(e) {
            _this.dragging = true;
            _this.decelerating = false;
            ptts = e.timeStamp;
            ptdrag.set(e.clientX, e.clientY, 0);
            disdrag.copy(ptdrag);
        });
        dom.addEventListener('mouseup', function(e) {
            _this.dragging = false;
            ptts = e.timeStamp - ptts;
            disdrag.subVectors(new THREE.Vector3(e.clientX, e.clientY, 0), disdrag);
            calc_decelerate();
        });
        dom.addEventListener('mousemove', function(e) {
            if (_this.dragging == false)
                return;            
            var pt = new THREE.Vector3(e.clientX, e.clientY, 0);
            var d = new THREE.Vector3();
            d.subVectors(pt, ptdrag);
            _this.ontouchaction(d);     
            ptdrag.copy(pt);
        });
        dom.addEventListener('touchstart', function(e) {
            var t = e.targetTouches[0];
            _this.dragging = true;
            _this.decelerating = false;
            ptts = e.timeStamp;            
            ptdrag.set(t.pageX, t.pageY, 0);
            disdrag.copy(ptdrag);
        });
        dom.addEventListener('touchend', function(e) {
            _this.dragging = false;
            ptts = e.timeStamp - ptts;
            var t = e.targetTouches[0];
            disdrag.subVectors(new THREE.Vector3(t.pageX, t.pageY, 0), disdrag);
            calc_decelerate();
        });
        dom.addEventListener('touchmove', function(e) {
            if (_this.dragging == false)
                return;
            var t = e.targetTouches[0];
            var pt = new THREE.Vector3(t.pageX, t.pageY, 0);
            var d = new THREE.Vector3();
            d.subVectors(pt, ptdrag);
            _this.ontouchaction(d);        
            ptdrag.copy(pt);
        });
    };
    var velo = new THREE.Vector3();
    var dvelo;
    var calc_decelerate = function() {
        velo.set(disdrag.x/ptts, disdrag.y/ptts, disdrag.z/ptts);
        if (Math.abs(velo.x) < 1)
            velo.x = 0;
        if (Math.abs(velo.y) < 1)
            velo.y = 0;
        if (Math.abs(velo.z) < 1)
            velo.z = 0;
        // 如果存在一个不大于零的，则代表需要启动定时器
        if (!velo.x && !velo.y && !velo.z) {
            _this.decelerating = false;
            return;
        }

        // 使用 cos 函数来做减速增益
        dvelo = 0;
        _this.decelerating = true;
    };

    this.nextframe = function() {
        if (_this.decelerating == false)
            return;

        var amp = Math.cos(dvelo);
        dvelo += Math.PI/180;
        velo.multiplyScalar(amp);
        if (Math.abs(velo.x) < 1)
            velo.x = 0;
        if (Math.abs(velo.y) < 1)
            velo.y = 0;
        if (Math.abs(velo.z) < 1)
            velo.z = 0;
        if (!velo.x && !velo.y && !velo.z) {
            setTimeout(function() {
                _this.decelerating = false;
            }, 1000);
            return;
        }
        
        // 继续偏移
        var d = new THREE.Vector3();
        d.copy(velo);
        d.multiplyScalar(10);
        _this.ontouchaction(d);
    };

    init();
    return this;
};

// 场景
var scene, camera, renderer;

// 元素
var earth;

// 热点，每一个热点就是一个片元
var hots = [];

!(function() {

    // 场景相关
    var light;

    // 交互相关
    var touchmgr = null;

    // 渲染
    onrender = function()
    {
        // 自动旋转
        if (touchmgr.dragging == false && touchmgr.decelerating == false)
        {
            earth.rotateOnAxis(new THREE.Vector3(0, 1, 0), Math.PI/360/6);
            for (var idx in hots) {
                var mesh = hots[idx];
                mesh.rotateOnAxis(new THREE.Vector3(0, 1, 0), Math.PI/360/6);
            }
        }
        // 触摸的管理
        touchmgr.nextframe();

        // 遍历每一个 face
        for (var idx in hots) {
            var mesh = hots[idx];
            var geo = mesh.geometry;

            var p = geo.vexparams;
	        var angn = p.angn;
	        var angv = p.angv;
	        var pos = p.pos;
	        var sco = p.sco;
	        var sct = p.sct;
         
	        for (var i = 0; i < geo.faces.length; i+=2) {
	            var f0 = geo.faces[i];
	            var f1 = geo.faces[i + 1];

	            var v0 = geo.vertices[f0.a];
	            var v2 = geo.vertices[f0.b];
	            var v1 = geo.vertices[f0.c];
	            var v3 = geo.vertices[f1.b];

	            // 如果 sct != 0，则代表需要缩放
                var ani = 1;
                if (sct) {
                    ani = sco + sct;
	                if (ani >= 1) {
	                    p.sct = -sct;
	                    ani = 1;
	                } else if (ani <= 0.5) {
	                    p.sct = -sct;
	                    ani = 0.5;
	                } else {
	                    ani += sct;
	                }
	                p.sco = ani;
                }

	            // 生成目标大小的平面
	            var plw = 32 * ani;
	            v0.set(-plw, plw, 0);
	            v1.set(plw, plw, 0);
	            v2.set(-plw, -plw, 0);
	            v3.set(plw, -plw, 0);
            
	            v0.applyAxisAngle(angn, angv);
	            v1.applyAxisAngle(angn, angv);
	            v2.applyAxisAngle(angn, angv);
	            v3.applyAxisAngle(angn, angv);

	            v0.add(pos);
	            v1.add(pos);
	            v2.add(pos);
	            v3.add(pos);
	        }
	        geo.verticesNeedUpdate = true;   
        }

        // 刷新屏幕
	    renderer.render(scene, camera);        
        requestAnimationFrame(onrender);
    };

    // 初始化场景
    oninit_scene = function()
    {
        scene = new THREE.Scene({antialias:true});
        //camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 10000);
        camera = new THREE.OrthographicCamera(window.innerWidth/ -1, window.innerWidth/1, window.innerHeight/1, window.innerHeight/ -1, 1, 10000);
        camera.position.set(0, 0, 5000);

        // 创建灯光
        light = new THREE.DirectionalLight(0xffffff, 2);
        light.position.set(100, 30, 30);
        scene.add(light);
        scene.add(new THREE.AmbientLight(0xffffff));

        // 创建地球
        var geo = new THREE.SphereGeometry(600, 50, 20);
        var tex = new THREE.ImageUtils.loadTexture('earth.jpg');
        var mat = new THREE.MeshLambertMaterial({map:tex, wireframe:false});
        earth = new THREE.Mesh(geo, mat);
        scene.add(earth);

        var factor = 13/12;
        // 创建大气层的贴图
        //geo = new THREE.PlaneBufferGeometry(512*factor, 512*factor);
        geo = new THREE.PlaneBufferGeometry(1230*factor, 1230*factor);
        tex = new THREE.ImageUtils.loadTexture('air.png');
        mat = new THREE.MeshLambertMaterial({map:tex, transparent:true});
        //mat = new THREE.MeshBasicMaterial({color:0xffffff});
        var mesh = new THREE.Mesh(geo, mat);
        mesh.position.z = 600*factor;
        scene.add(mesh);
        
        // 初始化渲染
        renderer = new THREE.WebGLRenderer({alpha:true});
        renderer.setSize(window.innerWidth, window.innerHeight);
        renderer.setClearColor(0x000000, 0);        
        document.body.appendChild(renderer.domElement);

        // 绑定交互动作
        touchmgr = new TouchManager(renderer.domElement);
        touchmgr.ontouchaction = update_interactive;

        // 启动渲染
        requestAnimationFrame(onrender);
    };

    update_interactive = function(d) {
        var xang = Math.PI/180 * d.x / 2;
        var yang = Math.PI/180 * d.y / 2;
        var zang = Math.PI/180 * d.z / 2;
        
        var matgt = new THREE.Matrix4();
        matgt.makeRotationFromEuler(new THREE.Euler(yang, 0, zang, 'XYZ'));
        matgt.multiply(earth.matrix);

        // 计算角度
        var ang = earth.up.clone().applyMatrix4(matgt).angleTo(earth.up);
        if (Math.abs(ang) > Math.PI/6) {
            matgt.makeRotationFromEuler(new THREE.Euler(0, 0, zang, 'XYZ'));
            matgt.multiply(earth.matrix);
        }
        //console.log("ang:" + ang);

        // 应用
        earth.matrix = matgt;
        matgt.decompose(earth.position, earth.quaternion, earth.scale);
        earth.rotateY(xang);
        
        //earth.applyMatrix(matgt);
        
        for (var idx in hots) {
            var mesh = hots[idx];

            mesh.matrix = matgt;
            matgt.decompose(mesh.position, mesh.quaternion, mesh.scale);
            //mesh.applyMatrix(matgt);
            mesh.rotateY(xang);
        }
    };
    
    // 初始化
    oninit = function() {
        // 创建地球
        oninit_scene();
        
        // 测试
        testHots();
    };

    window.onload = oninit;    
})();

// type 代表类型，0：普通的热点，1：源头的热点
function addHot(lng, lat, type) {
    // 计算出射线
    lng = -lng * Math.PI/180 + Math.PI/180;
    lat = lat * Math.PI/180;
    var ray = new THREE.Ray(new THREE.Vector3(), new THREE.Vector3(Math.cos(lat)*Math.cos(lng), Math.sin(lat), Math.cos(lat)*Math.sin(lng)).normalize());

    // 目标的对象
    var geo = earth.geometry;
    var pln = new THREE.Vector3(0, 0, 1);
    
    // 得出和射线相交的片元
    for (var idx in geo.faces)
    {
        var face = geo.faces[idx];
        
        // 生成出 triangle 来检查相交
        var facea = geo.vertices[face.a];
        var faceb = geo.vertices[face.b];
        var facec = geo.vertices[face.c];

        var ptinsect = ray.intersectTriangle(facea, faceb, facec);
        if (ptinsect) {
            // 生成片元
            var facen = face.normal;
            
            var angv = pln.angleTo(facen);
            var angn = new THREE.Vector3();
            angn.crossVectors(pln, facen).normalize();

            // 需要根据当前的位置偏移 plane 中的点
            var pta = new THREE.Vector3();
            var ptb = new THREE.Vector3();
            var ptc = new THREE.Vector3();
            var ptd = new THREE.Vector3();

            // 根据 threejs 的文档，生成新的mesh（不能修改 mesh 中的元素，只能新建一个）
            var geo = new THREE.Geometry();

            // 保存一下参数，以用来在渲染中放大
            var sco = THREE.Math.randFloat(0, 1); // 初始的放大系数
            // 旋转法线、夹角、位置、起始缩放、缩放的步数、类型
            geo.vexparams = {"angn":angn, "angv":angv, "pos":ptinsect, "sco":sco, "sct":0.005};
            if (type == 1)
                geo.vexparams.sct = 0;

            // 添加顶点
            var vl = geo.vertices.length;
            geo.vertices.push(pta, ptb, ptc, ptd);
            geo.faces.push(new THREE.Face3(vl, vl+2, vl+1, facen));
            geo.faces.push(new THREE.Face3(vl+2, vl+3, vl+1, facen));
            geo.faceVertexUvs[0].push([new THREE.Vector2(0, 1), new THREE.Vector2(0, 0), new THREE.Vector2(1, 1)]);
            geo.faceVertexUvs[0].push([new THREE.Vector2(0, 0), new THREE.Vector2(1, 0), new THREE.Vector2(1, 1)]);

            // 生成片元
            var tex = null;
            if (type == 1)
                tex = new THREE.ImageUtils.loadTexture('hot2.png');
            else
                tex = new THREE.ImageUtils.loadTexture('hot.png');
            var mat = new THREE.MeshPhongMaterial({map:tex, transparent:true, shininess:0, depthTest:false});
            var plic = new THREE.Mesh(geo, mat);
            scene.add(plic);
            hots.push(plic);

            //console.log("add a hot face, faceid " + idx);
            break;
        }
    }
}

function testHots() {
    addHot(120, 36);
    addHot(121, 35);
    addHot(118, 35);
    addHot(122, 34);
    addHot(117, 33);
    addHot(118, 34);
    addHot(117, 31);
    addHot(112, 33);

    addHot(120, 26, 1);
    addHot(121, 25, 1);
    addHot(118, 25, 1);
    addHot(122, 24, 1);
    addHot(117, 23);
    addHot(118, 24);
    addHot(117, 21);
    addHot(112, 23);

    addHot(4, 1);
    addHot(5, 1);
    addHot(6, 1);
    addHot(7, 1);
    addHot(8, 1);
    addHot(9, 1);
    addHot(6, 1);
    addHot(7, 1);
};
