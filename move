using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class move : MonoBehaviour
{
    [SerializeField] private input_Controller input = null;
    [SerializeField, Range(0f, 100f)] public float _maxSpeed = 4f;
    [SerializeField, Range(0f, 100f)] public float _maxAcceleration = 35f;
    [SerializeField, Range(0f, 100f)] private float _maxAirAcceleration = 20f;
    [SerializeField, Range(0.05f, 1f)] private float _wallStickTime = 0.2f;

    private Vector2 _direction;
    private Vector2 _desiredVelocity;
    private Vector2 _velocity;
    private Rigidbody2D _rb;
    private collision_Data_Retriever _collisonDataRetreiver;
    private wall_Interacter _wallInteracter;

    private float _maxSpeedChange;
    private float _acceleration;
    private float _wallStickCounter;
    private bool _onGround;


    // Start is called before the first frame update
    void Awake()
    {
        _rb = GetComponent<Rigidbody2D>();
        _collisonDataRetreiver = GetComponent<collision_Data_Retriever>();
        _wallInteracter = GetComponent<wall_Interacter>();
    }

    private void Start()
    {
        transform.position = game_Manager.instance.lastCheckpointPos;
    }

    // Update is called once per frame
    void Update()
    {
        _direction.x = input.retrieveMoveInput();
        _desiredVelocity = new Vector2(_direction.x, 0f) * Mathf.Max(_maxSpeed - _collisonDataRetreiver.friction, 0f);

        if (Input.GetKeyDown(KeyCode.Tab))
        {
            SceneManager.LoadScene(0);
        }
    }

    private void FixedUpdate()
    {
        _onGround = _collisonDataRetreiver.onGround;
        _velocity = _rb.velocity;

        _acceleration = _onGround ? _maxAcceleration : _maxAirAcceleration;
        _maxSpeedChange = _acceleration * Time.deltaTime;
        _velocity.x = Mathf.MoveTowards(_velocity.x, _desiredVelocity.x, _maxSpeedChange);

        #region Wall Stick
        if (_collisonDataRetreiver.onWall && !_collisonDataRetreiver.onGround && !_wallInteracter.wallJumping)
        {
            if (_wallStickCounter > 0)
            {
                _velocity.x = 0;

                if (input.retrieveMoveInput() == _collisonDataRetreiver.contactNormal.x)
                {
                    _wallStickCounter -= Time.deltaTime;
                }
                else
                {
                    _wallStickCounter = _wallStickTime;
                }
            }
            else
            {
                _wallStickCounter = _wallStickTime;
            }
        }
        #endregion

        _rb.velocity = _velocity;
    }
}
