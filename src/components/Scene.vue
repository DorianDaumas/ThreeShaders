<template>
  <div class="scene">
    <div id="three-scene-canvas">
      <div id="positionOptions">
        <select class="input" @change="changeDisplacement" v-model="selected">
          <option v-for="option in options" v-bind:value="option.value" :key="option.value">
           Effect: {{ option.text }}
          </option>
        </select>

        <select class="input" @change="changeImage" v-model="selectedImage">
          <option v-for="option in optionsImage" v-bind:value="option.value" :key="option.value">
            Image: {{ option.text }}
          </option>
        </select>

        <button style="margin-top: 50px" class="input" v-if="clickedTransformation" @click='onClick'>Désactiver</button>
        <button style="margin-top: 50px" class="input" v-else @click='onClick'>Activer</button>

      </div>
    </div>
  </div>
</template>

<script>
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import vertex from "./shaders/vertex.glsl";
import fragment from "./shaders/fragment.glsl";
import image from '../assets/pexels-photo-792381.jpeg';
import image2 from '../assets/cheetah-leopard-animal-big-87403.jpeg';
import image3 from '../assets/squirrel-animal-cute-rodents-47547.jpeg';
import displacement1 from "../assets/HsGbA.png";
import displacement2 from "../assets/Rocks_Hexagons_001_height.png";
import displacement3 from "../assets/LzwWsEzqM4.jpg";
import * as dat from 'dat.gui';
import gsap from "gsap";


export default {
  name: 'Scene',
  data () {
    return {
      sceneCanvas: null,
      scene: null,
      camera: null,
      renderer: null,
      controls: null,
      time: 0,
      material:null,
      settingsGUI: null,
      settingsImage: null,
      startTime: Date.now(),
      mouse:null,
      clickedTransformation: false,
      selected: displacement1,
      choosenDisplacement: displacement1,
      options: [
        { text: 'Waves', value: displacement1 },
        { text: 'Hexagon', value: displacement2 },
        { text: 'Ripple', value: displacement3 }
      ],
      selectedImage: image, 
      choosenImage: image,
      optionsImage: [
        { text: 'Tigre', value: image },
        { text: 'Leopard', value: image2 },
        { text: 'Eccureuil', value: image3 }
      ]
    }
  },
  mounted () {
    this.initScene()
    window.addEventListener('resize', () => {this.windowResize()})
  },

  methods: {
    


    initScene(){
      /* **************
        BASIC SETUP
      ************** */
      this.sceneCanvas = document.getElementById('three-scene-canvas')
      this.scene = new THREE.Scene()
      this.camera = new THREE.PerspectiveCamera(70, window.innerWidth / window.innerHeight,0.001,1000)
      this.camera.position.set(0, 0, 1)
      
      // render
      this.renderer = new THREE.WebGLRenderer({
        antialias: true,
        powerPreference: "high-performance"
      })
      this.renderer.outputEncoding = THREE.sRGBEncoding
      this.controls = new OrbitControls(this.camera, this.renderer.domElement)
      this.renderer.setClearColor("#212121")
      this.renderer.setPixelRatio( window.devicePixelRatio );
      this.renderer.setSize(window.innerWidth, window.innerHeight);
      this.renderer.shadowMap.enabled = true
      this.renderer.shadowMap.type = THREE.PCFSoftShadowMap
      this.renderer.shadowMapSoft = true
      this.renderer.shadowMap.autoUpdate = false
      this.renderer.shadowMap.needsUpdate = true
      this.sceneCanvas.append(this.renderer.domElement)

      
      // light
      let ambientLight = new THREE.AmbientLight (0xdaccff, 0.5)
      this.scene.add(ambientLight)
      let light = new THREE.PointLight(0xfc831d, 1, 100)
      light.position.set(15, 10, 15)
      light.castShadow = true
      light.shadow.radius = 1
      light.shadow.mapSize.width = 2048
      light.shadow.mapSize.height = 2048
      this.scene.add(light)

      // cube & shaders ( GLSL )
      let geometry = new THREE.PlaneBufferGeometry(1,1)
      this.material = new THREE.ShaderMaterial({
        side: THREE.DoubleSide,

        uniforms:{
          time: {type: "f", value: 0 },
          mouse: {type: "v3", value: new THREE.Vector3() },
          progress: {type: "f", value: 0 },
          image: { type: "t", value: new THREE.TextureLoader().load(image)},
          displacement: { type: "t", value: new THREE.TextureLoader().load(displacement1)},
          resolution: {type: "v4", value: new THREE.Vector4() },
          uvRate1:{
            value: new THREE.Vector2(1,1)
          }
        },

        fragmentShader: fragment,
        vertexShader: vertex,
        
      })
      let cube = new THREE.Mesh(geometry, this.material)
      this.scene.add(cube)
      this.settings()
      this.animateThreeJs()
      document.addEventListener( 'mousemove', this.onMouseMove, false );
    },

    //GUI
    settings(){
      this.settingsGUI = {
        progress: 0,
      };
      this.settingsImage = {
        image: image
      }
      // const gui = new dat.GUI();
      // gui.add(this.settingsGUI, "progress", 0,1,0.01)
      // gui.add(this.settingsImage, 'image', [ image, image2, image3 ] );
    },

    changeDisplacement(event){ 
      this.material.uniforms.displacement.value = new THREE.TextureLoader().load(event.target.value)
    },

    changeImage(event){ 
      this.material.uniforms.image.value = new THREE.TextureLoader().load(event.target.value)
    },

    //trigger animation shaders on click
    onClick() {
      let tl = gsap.timeline();

      this.clickedTransformation = !this.clickedTransformation
      if (this.clickedTransformation) {
        tl.to(this.settingsGUI, {duration: 1, progress: .45})
      }
      else{
        this.time = 0;
        tl.to(this.settingsGUI, {duration: 1, progress: 0})
      }
    },

    // resize
    windowResize(){
      this.camera.aspect = window.innerWidth / window.innerHeight;
      this.camera.updateProjectionMatrix()
      this.renderer.setSize(window.innerWidth, window.innerHeight);
    },

    // animate
    animateThreeJs () {
      if (this.settingsGUI.progress === 0) {
        this.time = 0  
      }
      else{
        this.time += 0.001;
      }
      this.material.uniforms.time.value = this.time 
      this.material.uniforms.progress.value = this.settingsGUI.progress
      this.controls.update();
      this.renderer.shadowMap.needsUpdate = true
      this.renderer.render(this.scene, this.camera)
      requestAnimationFrame(this.animateThreeJs)
    },

  }
}

</script>

<style >
  #three-scene-canvas {
    width: 100%;
    height: 100vh;
    overflow: hidden;
  }

  #positionOptions{
    position: absolute;
    top: 260px;
    left: 40px;
    display: flex;
    flex-direction: column;
    height: 50px;
  }
  .input{
    padding: 10px;
    background: #0a0a0a;
    color: white;
    outline: none;
    margin-top: 5px;
    border: none;
    border-left: 2px solid; 
  }

</style>